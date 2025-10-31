///|
fn run_async(f : async () -> Int) -> Int = "%async.run"

///|
fn run_async_unit(f : async () -> Unit) -> Unit = "%async.run"

///|
fn run_async_bool(f : async () -> Bool) -> Bool = "%async.run"
