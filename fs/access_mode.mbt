///|
let _A_READ = 1

///|
let _A_WRITE = 2

///|
let _A_EXECUTE = 4

///|
pub struct AccessMode(Int)

///|
pub fn AccessMode::new(
  read? : Bool=false,
  write? : Bool=false,
  execute? : Bool=false,
) -> AccessMode {
  let mut flag = 0
  if read {
    flag = flag | _A_READ
  }
  if write {
    flag = flag | _A_WRITE
  }
  if execute {
    flag = flag | _A_EXECUTE
  }
  flag
}

pub fn read(self: AccessMode) -> Bool{
  (self.0 & _A_READ) != 0
}
pub fn write(self: AccessMode) -> Bool{
  (self.0 & _A_WRITE) != 0
}
pub fn execute(self: AccessMode) -> Bool{
  (self.0 & _A_EXECUTE) != 0
}
