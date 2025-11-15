///|
struct LibuvRuntime {
  uv : @uv.Loop
  mut task_counter : Int
}

///|
pub fn LibuvRuntime::new(_loop : @uv.Loop) -> LibuvRuntime {
  return { uv: _loop, task_counter: 0 }
}

///|
let default_uv : Ref[LibuvRuntime?] = Ref::new(None)

///|
pub fn LibuvRuntime::default() -> LibuvRuntime raise {
  guard default_uv.val is None else { return default_uv.val.unwrap() }
  let uv = @uv.Loop::new()
  let rt = LibuvRuntime::{ uv, task_counter: 0 }
  default_uv.val = Some(rt)
  return rt
}

///|
pub impl @rt.Runtime for LibuvRuntime with new_task(self, task) {
  self.task_counter += 1
  return UvTask::{
    id: self.task_counter,
    cancel_handle: () => (),
    exit_handler: _ => (),
    state: New,
    rt: self,
    task,
  }
}

///|
pub impl @rt.Runtime for LibuvRuntime with unsafe_suspend(_, f) {
  uvrt_suspend((resolve, reject, task) => f(resolve, reject, task))
}

///|
pub impl @rt.Runtime for LibuvRuntime with sleep(self, time_millis) {
  let timer = @uv.Timer::new(self.uv)
  uvrt_suspend((resolve, reject, _) => {
    timer.start(timeout=time_millis, repeat=0, t => t.close(() => resolve(()))) catch {
      err => reject(err)
    }
    () => {
      defer reject(@rt.CoroutineError::Cancelled)
      timer.stop()
    }
  })
}

///|
pub enum ExitType {
  Cancelled
  UnhandledError
  Done
  Any
} derive(Eq, Hash)

///|
/// TODO: it can be even smaller
struct UvTask {
  id : Int
  mut cancel_handle : async () -> Unit
  mut exit_handler : (ExitType) -> Unit
  mut state : @rt.TaskState
  task : async (&@rt.Task) -> Unit
  rt : LibuvRuntime
}

///|
fn UvTask::on_exit(
  self : UvTask,
  _type : ExitType,
  handler : () -> Unit,
) -> () -> Unit {
  if self.state == Completed || self.state == Cancelled {
    handler()
    return () => ()
  }
  let og = self.exit_handler
  let mut cancel = false
  self.exit_handler = type_ => {
    defer og(type_)
    if !cancel && type_ == _type {
      handler()
    }
  }
  () => cancel = true
}

///|
fn UvTask::_cleanup_exit(self : UvTask, _type : ExitType) -> Unit {
  guard _type != Any
  (self.exit_handler)(_type)
}

///|
pub impl @rt.Task for UvTask with id(self) {
  self.id
}

///|
pub impl @rt.Task for UvTask with state(self) {
  self.state
}

///|
pub impl @rt.Task for UvTask with start(self) {
  let handle = @uv.Async::new(self.rt.uv, _async => ___run_async(() => {
    self.state = Running
    // prevent memory leak
    push_coroutine(self)
    defer (fn() {
      pop_coroutine() |> ignore
      self.cancel_handle = () => ()
    })()
    try (self.task)(self) catch {
      e =>
        match e {
          @rt.CoroutineError::Cancelled => {
            self.state = Cancelled
            self._cleanup_exit(ExitType::Cancelled)
          }
          _ => {
            self.state = Cancelled
            self._cleanup_exit(ExitType::UnhandledError)
          }
        }
    } noraise {
      _ => {
        self.state = Completed
        self._cleanup_exit(ExitType::Done)
      }
    }
  }))
  self.cancel_handle = () => ___suspend((
    res,
    _, // no need to store context ..
  ) => handle.close(() => res(())))
}

///|
pub impl @rt.Task for UvTask with join(self) {
  match self.state {
    Cancelled | Completed => ()
    Cancelling | Suspend | Running =>
      uvrt_suspend((resolve, reject, _) => {
        let cancelToken = self.on_exit(ExitType::Any, () => resolve(()))
        () => {
          cancelToken()
          reject(@rt.CoroutineError::Cancelled)
        }
      })
    New => {
      // enqueue the task and wait for it
      self.start()
      self.join()
    }
  }
}

///|
pub impl @rt.Task for UvTask with cancel(self) {
  match self.state {
    Cancelling | Cancelled => ()
    Suspend => {
      self.state = Cancelling
      (self.cancel_handle)()
    }
    Running => self.state = Cancelling // this only happens when the task is cancelling itself.
    New => self.state = Cancelled
    Completed => ()
  }
}
