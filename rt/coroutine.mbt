///|
/// A TaskState indicates the execution state of a corresponding Task.
/// Running: The Task is executing on a thread
/// Only one Task can be ran for one carrier thread. However, `Suspend` thread may migrate to other
/// carriers if any carriers available.
/// 
/// Suspend: The Task has reached a suspension and currently dismounted from a thread.
/// Suspend usually happens at I/O executions, like reading a file, etc. Once the Task reached those operations,
/// the runtime should collect the context via async primitives and set the Task state to `Suspend`
/// 
/// Completed: The Task is terminated and won't be continued to neither run nor cancel.
/// 
/// Cancelled: The Task is already cancelled.
/// Whenever a Task is being cancelled,it threw an Interruption error on the state transition.
pub enum TaskState {
  New
  Running
  Suspend
  Cancelled
  Completed
} derive(Eq, Hash, Show)

// todo TaskScope Value

///|
pub trait Task {
  id(Self) -> Int
  state(Self) -> TaskState
  ///| Can only call on TaskState==New.
  /// The underlying runtime will run this task in _background_.
  start(Self) -> Unit
  ///| Suspend until this job has been completed.
  async join(Self) -> Unit
  ///| Cancel this task. 
  /// When a task is being cancelled, the user will synchronize with the job
  async cancel(Self) -> Unit
  is_cancelling(Self) -> Bool
}

///|
/// A Job provides necessary information for the executed codes to fork or cancel themselves.
pub struct Job {
  context : Context
  task : &Task
}

///|
pub struct Context { // share information in tasks, manage jobs in batch, etc.
  priv mut cancelled : Bool
  priv rt : &Runtime
  priv tasks : Map[Int, &Task]
  priv children : Array[Context]
  parent : Context
}

///|
pub fn is_cancelled(self : Context) -> Bool {
  self.cancelled
}

// A shortcut of cancel, but run in background thus does not require synchronisation.

///|
pub fn bg_cancel(self : Context) -> Unit {
  self.rt.new_task(_ => self.cancel()).start()
}

///|
/// Synchronize and cancel all the tasks and childrens.
/// Errors caused by cancellation will be silently ignored.
pub async fn cancel(self : Context) -> Unit {
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
pub async fn[T] job(self : Context, task : async (Job) -> T) -> &Task {
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
pub async fn[T] job_timeout(
  self : Context,
  timeoutMillis : Int64,
  task : async (Job) -> T,
) -> &Task {
  self.rt.new_task(t => {
    let mut done = false
    let timeoutTask = self.job(_ => {
      self.rt.sleep(timeoutMillis / 1000) catch {
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
pub async fn join(self : Context) -> Unit {
  while self.tasks.length() > 0 {
    self.rt._co_yield()
    // maybe a sleep here ... 
    // also need to garanteer no jobs are dead but not tracked!
    // what if we join from one of our tasks?
  }
}

///|
pub fn fork(self : Context) -> Context {
  let ctx = Context::{
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
pub async fn with_context(
  self : Context,
  action : async (Context) -> Unit,
) -> Unit {
  let context = self.fork()
  defer context.bg_cancel()
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
  current_job().context.rt._co_yield()
  // for main it runs in an anonymosus top context.
}
