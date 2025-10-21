///|
fn run_async(f : async () -> Unit noraise) -> Unit = "%async.run"

///|
async fn[T, E : Error] suspend(
  f : (
    (T) -> Unit, // onResolve
    (E) -> Unit, // onReject
  ) -> Unit, // Thenable
) -> T raise E = "%async.suspend"

///|
fn run_async_main(main : async () -> Unit) {
  try {
    
    let uv = @uv.Loop::new()
    uv.fs_chmod()
  }
}
