///|
pub struct BasicContext { // share information in tasks, manage jobs in batch, etc.
  priv mut cancelled : Bool
  priv rt : &Runtime
  priv tasks : Map[Int, &Task]
  priv children : Array[&Context]
  parent : &Context
}

///|
pub impl Context for BasicContext with is_cancelled(self) {
  self.cancelled
}

///| TODO: Considering deprecate this in favor of an internal thread-local variable.
pub impl Context for BasicContext with runtime(self) {
  self.rt
}

// A shortcut of cancel, but run in background thus does not require synchronisation.

///|
pub impl Context for BasicContext with cancel_in_bg(self) {
  self.rt.new_task(_ => self.cancel()).start()
}

///|
/// Synchronize and cancel all the tasks and childrens.
/// Errors caused by cancellation will be silently ignored.
pub impl Context for BasicContext with cancel(self) -> Unit {
  self.cancelled = true
  for child in self.children {
    child.cancel() catch {
      err => () // logging?
    }
  }
  let tasks = self.tasks.values().to_array()
  for task in tasks {
    if !task.is_cancelling() {
      task.cancel() catch {
        err => () // logging?
      }
    }
  }
  self.join() // wait for completion...
  self.tasks.clear()
  self.children.clear()
}

///|
/// Create a Task associated with this Context.
pub impl Context for BasicContext with job(self, task) -> &Task {
  guard !self.cancelled else {
    raise fail("The context is already cancelled! (new_job)")
  }
  let taskToken = self.rt.new_task(t => {
      // It can keep the state tracked even if the user called cancel() on returned tasks.
      defer self.tasks.remove(t.id())
      Job::{ context: self, task: t } |> task |> ignore
    })
  self.tasks[taskToken.id()] = taskToken
  taskToken
}

///|
pub impl Context for BasicContext with job_timeout(self, timeout_millis~, task) -> &Task {
  self.rt.new_task(t => {
    let mut done = false
    let timeoutTask = self.job(_ => {
      self.rt.sleep(timeout_millis / 1000) catch {
        _ => () // likely a cancellation
      }
      if !done {
        raise fail("Timeout exceeded for job \{t.id()}")
      }
    })
    timeoutTask.start()
    self
    .job(j => {
        defer (fn() { done = true })()
        try task(j) catch {
          err => {
            timeoutTask.cancel()
            raise err
          }
        } noraise {
          v => {
            timeoutTask.cancel()
            v
          }
        }
      })
    .start()
  })
}

///|
pub impl Context for BasicContext with join(self) -> Unit {
  while self.tasks.length() > 0 {
    self.rt._co_yield()
    // maybe a sleep here ... 
    // also need to garanteer no jobs are dead but not tracked!
    // what if we join from one of our tasks?
  }
}

///|
pub impl Context for BasicContext with fork(self) -> &Context {
  let ctx = BasicContext::{
    rt: self.rt,
    tasks: {},
    children: [],
    parent: self,
    cancelled: false,
  }
  self.children.push(ctx)
  ctx
}

// shortcut

///|
pub impl Context for BasicContext with with_context(self, action) -> Unit {
  let context = self.fork()
  defer context.cancel_in_bg()
  action(context)
}

///|
fn[T, E] suspend(f : ((T) -> Unit, (E) -> Unit) -> Unit) = "%async.suspend"

///|
async fn _co_yield(self : &Runtime) -> Unit {
  suspend((r, _) => self.new_task(_ => r(())).start())
}

///|
extern "C" fn current_job() -> Job = "moonbit_miao_current_job" // should implement this by a threadlocal stack

///|
extern "C" fn set_current_job(current : Job) = "moonbit_miao_set_current_job"

///|
/// Yields out the execution to another coroutine.
/// This depends on a installed runtime or may cause undefined behaviour.
pub async fn co_yield() -> Unit {
  current_job().context.runtime()._co_yield()
  // for main it runs in an anonymosus top context.
}
