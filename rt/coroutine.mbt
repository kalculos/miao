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
/// A Task describes the state of a coroutine, which is managed by runtime and cooperating with other coroutines to utilize
/// time slices between IO operations with the help of runtime. 
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
  context : &Context
  task : &Task
}

///|
pub typealias async (Job) -> Unit as Coroutine

///|
/// A Context manages multiple Tasks in batch to enable structured concurrency, while 
/// utilities like timeout and cancellation are also provided.
/// 
/// Contexts are independent from any specific runtime implementations.
pub trait Context {
  runtime(Self) -> &Runtime
  is_cancelled(Self) -> Bool
  cancel_in_bg(Self) -> Unit
  async cancel(Self) -> Unit
  async job(Self, task : Coroutine) -> &Task
  async job_timeout(Self, timeout_millis~ : Int64, task : Coroutine) -> &Task
  async join(Self) -> Unit
  fork(Self) -> &Context
  async with_context(Self, (&Context) -> Unit) -> Unit
}
