///|
async fn[T, E : Error] suspend(f : ((T) -> Unit, (E) -> Unit) -> Unit) -> T raise E = "%async.suspend"

///|
fn run_async(f : async () -> Unit noraise) -> Unit = "%async.run"

///|
async fn _co_yield(self : &Runtime) -> Unit {
  suspend((r, _) => try self.new_task(_ => r(())).start() catch {
    err => println("Failed to submit task for _co_yield: \{err}")
  })
}

///|
let default_runtime : Ref[&Runtime?] = Ref::new(None)
