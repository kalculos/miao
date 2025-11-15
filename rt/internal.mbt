///|
async fn[T, E : Error] suspend(
  f : ((T) -> Unit, (E) -> Unit) -> Unit,
) -> T raise E = "%async.suspend"

///|
async fn &Runtime::_co_yield(self : &Runtime) -> Unit {
  suspend((r, _) => self.new_task(_ => r(())).start() catch {
      err => println("Failed to submit task for _co_yield: \{err}")
    })
}

///|
pub let _current_runtime : Ref[() -> &Runtime] = Ref::new(() => {
  println("RUNTIME IS NOT INITIALIZED YET")
  panic()
})

///|
pub fn current_runtime() -> &Runtime {
  (_current_runtime.val)()
}
