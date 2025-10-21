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
/// Dead: The Task is terminated and won't be continued to run.
/// It is observable because you're holding a reference to the Task. Users of the Task object should NOT keep
/// the reference alive once post processings are done since its likely to leak memory.
/// 
/// Cancelling/Cancelled: The Task is requested to be cancelled or already cancelled.
/// Whenever a Task is being cancelled,it threw an Interruption error on the state transition.
/// To be more specifically, the interruption mechanism can be triggered via setting Task#interrupted to true.
pub enum TaskState {
  New
  Running
  Suspend
  Cancelling
  Calcelled
  Dead
} derive(Eq, Hash, Show)

// todo TaskScope Value

///|
pub trait Task {
  id(Self) -> Int
  state(Self) -> TaskState
  ///| Setting the state is actually advising the runtime to make a transition.
  /// It may not succeed.
  set_state(Self, TaskState) -> Unit
}

///|
/// A Job provides necessary information for the executed codes to fork or cancel themselves.
pub struct Job {
  context : Context
  cancel : () -> Unit
}

///|
pub struct Context { // share information in tasks, manage jobs in batch, etc.
  priv rt : &Runtime
  priv tasks : Map[Int, &Task]
  priv children : Array[Context]
  parent : Context
  priv mut closed : Bool
}

///|
pub fn[T] new_job(self : Context, task : async (Job) -> T) -> &Task {
  let taskToken = self.rt.new_task(t => {
      defer self.tasks.remove(t.id())
      Job::{ context: self, cancel: () => t.set_state(Cancelling) }
      |> task
      |> ignore
    })
  self.tasks[taskToken.id()] = taskToken
  taskToken //todo: handle direct cancel() calls on the task, by providing a wrapper.
}

///|
pub fn[T] run_job(self : Context, task : async (Job) -> T) -> &Task {
  let job = self.new_job(task)
  job.set_state(Running) |> ignore
  job
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
pub async fn cancel(self : Context) -> Unit {
  for child in self.children {
    child.cancel()
  }
  for task in self.tasks.values() {
    task.set_state(Cancelling) |> ignore
  }
  self.join() // wait for completion...
}

///|
pub fn fork(self : Context) -> Context {
  let ctx = Context::{
    rt: self.rt,
    tasks: {},
    children: [],
    parent: self,
    closed: false,
  }
  self.children.push(ctx)
  ctx
}

///|
fn[T, E] suspend(f : ((T) -> Unit, (E) -> Unit) -> Unit) = "%async.suspend"

///|
async fn _co_yield(self : &Runtime) -> Unit {
  suspend((r, _) => self.new_task(_ => r(())) |> ignore)
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

///|
async fn async_main(context : Context) -> Unit {
  let child = context.fork()
  // let results = Array::new(0) // or a more robust one, mpsc
  let task = child.new_job(job => {
    if 11122 % 232 > 0 {
      (job.cancel)()
    }
    // the returned value may be ignored if the context isn't
    // interested in the value (otherwise like, a collector context)
    // results.push(114514)
    114514
  })
  task.set_state(Running)
  child.cancel()
  // or ...
  child.join()
}
