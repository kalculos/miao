///|
pub(open) trait Runtime {
  default_file_system(Self) -> &@fs.FileSystem
  // will not immediately run
  new_task(Self, task : async (&Task) -> Unit) -> &Task
  run_task(Self, task : async (&Task) -> Unit) -> Unit = _
}

///|
impl Runtime with run_task(self, task) {
  self.new_task(task).set_state(Running)
}