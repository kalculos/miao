///|
fn[T, E] suspend(f : ((T) -> Unit, (E) -> Unit) -> Unit) = "%async.suspend"

///|
fn run_async(f : async () -> Unit) -> Unit = "%async.run"

///|
async fn _co_yield(self : &Runtime) -> Unit {
  suspend((r, _) => self.new_task(_ => r(())).start())
}

///|
extern "C" fn current_job() -> Job = "moonbit_miao_current_job" // should implement this by a threadlocal stack

///|
extern "C" fn set_current_job(current : Job) = "moonbit_miao_set_current_job"
