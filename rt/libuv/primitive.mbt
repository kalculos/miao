///|
fn ___run_async(f : async () -> Unit noraise) -> Unit = "%async.run"

///|
async fn[T, E : Error] ___suspend(
  f : (
    (T) -> Unit, // onResolve
    (E) -> Unit, // onReject
  ) -> Unit, // Thenable
) -> T raise E = "%async.suspend"

///|
typealias () -> Unit raise as UvCancellationToken

///|
/// This method automatically invalidates the uvCancellationToken after coroutine continued to run (or cancelled)
async fn[T] uvrt_suspend(
  f : ((T) -> Unit, (Error) -> Unit, UvTask) -> UvCancellationToken,
) -> T raise @rt.CoroutineError {
  guard pop_coroutine() is Some(task) else {
    println(
      "WARNING: Job not running in a UvTask calling uvrt_suspend. Haven't you set default_runtime nor use with_runtime in your main fn?",
    )
    println("Unexpected behaviour is occurred. Program exiting")
    panic()
  }
  guard task.state == Running else {
    if task.state != Cancelling {
      println("Expect task state Running | Cancelling but got \{task.state}.")
      println("This is possibly a runtime bug! Interrupting as cancelled...")
    }
    raise @rt.CoroutineError::Cancelled
  }
  let og_cancel_handle = task.cancel_handle
  defer (fn() { task.cancel_handle = og_cancel_handle })()
  defer push_coroutine(task)
  task.state = Suspend
  return try
    ___suspend((a, b) => {
      let cToken = f(a, b, task)
      task.cancel_handle = () => {
        // reset to empty
        task.cancel_handle = () => ()
        cToken()
      }
    })
  catch {
    e => {
      if task.state == Cancelling {
        raise @rt.CoroutineError::Cancelled
      }
      task.state = Running
      raise @rt.CoroutineError::ExecutionError(e)
    }
  } noraise {
    result => {
      guard task.state != @rt.TaskState::Cancelled else {
        raise @rt.CoroutineError::Cancelled
      }
      task.state = Running
      result
    }
  }
}

///|
extern "C" fn __has_coroutine() -> Bool = "moonbit_uvrt_has_coroutine"

///|
extern "C" fn __current_coroutine() -> UvTask = "moonbit_uvrt_current_coroutine"

///|
/// this function returns its identity.
extern "C" fn __push_coroutine_stack(task : UvTask) -> UvTask = "moonbit_uvrt_push_coroutine_stack"

///|
extern "C" fn __pop_coroutine_stack() -> UvTask = "moonbit_uvrt_pop_coroutine_stack"

///|
pub fn current_coroutine() -> UvTask? {
  if __has_coroutine() {
    return Some(__current_coroutine())
  }
  None
}

///|
fn pop_coroutine() -> UvTask? {
  guard __has_coroutine() else { return None }
  Some(__pop_coroutine_stack())
}

///|
fn push_coroutine(task : UvTask) -> Unit{
  __push_coroutine_stack(task) |> ignore // it returns itself.
}
