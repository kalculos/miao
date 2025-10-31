///|
pub struct TcpOption(Int)

///|
let _REUSE_ADDR = 1

///|
pub fn TcpOption::new(reuseaddr? : Bool = false) -> TcpOption {
  let mut flag = 0
  if reuseaddr {
    flag = flag | _REUSE_ADDR
  }
  TcpOption(flag)
}

///|
pub fn TcpOption::reuseaddr(self : TcpOption) -> Bool {
  (self.0 & _REUSE_ADDR) != 0
}
