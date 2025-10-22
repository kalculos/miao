///|
fn[T, E] suspend(f : ((T) -> Unit, (E) -> Unit) -> Unit) = "%async.suspend"

///|
fn run_async(f : async () -> Unit) -> Unit = "%async.run"

///|
async fn _co_yield(self : &Runtime) -> Unit {
  suspend((r, _) => self.new_task(_ => r(())).start())
}

///|
let default_runtime : Ref[&Runtime?] = Ref::new(None)

///|
pub fn get_default_runtime() -> &Runtime? {
  default_runtime.val
}
