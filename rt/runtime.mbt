///|
pub(open) trait Runtime {
  default_file_system(Self) -> &@fs.FileSystem
  // will not immediately run until start() is invoked
  new_task(Self, task : async (&Task) -> Unit) -> &Task
  async sleep(Self, timeNanos: Int64) -> Unit

}