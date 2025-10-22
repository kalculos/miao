///|
pub(open) trait Runtime {
  default_file_system(Self) -> &@fs.FileSystem
  // will not immediately run until start() is invoked
  new_task(Self, task : async (&Task) -> Unit) -> &Task
  async sleep(Self, timeNanos : Int64) -> Unit
}

///|
pub fn run_with_runtime(rt : &Runtime, main : Coroutine) -> Unit raise {
  guard default_runtime.val is None else {
    raise fail("A default runtime cannot be initialized twice.")
  }
  default_runtime.val = Some(rt)
  @fs.set_default_fs(rt.default_file_system())
  let context = BasicContext::new(rt)
  run_async(() => context.job(main).join())
}

///|
pub fn get_default_runtime() -> &Runtime? {
  default_runtime.val
}
