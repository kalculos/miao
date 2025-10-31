///|
struct Position {
  x : Int
  y : Int
  z : Int
}

///|
const POSITION_X_SIZE = 26

///|
const POSITION_Y_SIZE = 12

///|
const POSITION_Z_SIZE = 26

///|
pub fn read_position(buf : &@buffer.Buffer) -> Position raise {
  let val = buf.read_int64()
  let x = (val >> (POSITION_Y_SIZE + POSITION_Z_SIZE)).to_int()
  let y = (val <<
  (POSITION_X_SIZE + POSITION_Z_SIZE) >>
  (POSITION_X_SIZE + POSITION_Z_SIZE)).to_int()
  let z = (val << POSITION_X_SIZE >> (POSITION_X_SIZE + POSITION_Y_SIZE)).to_int()
  Position::{ x, y, z }
}

///|
pub fn write_position(buf : &@buffer.Buffer, position : Position) -> Unit {
  let x = position.x.to_int64() << (POSITION_Y_SIZE + POSITION_Z_SIZE)
  let y = position.y.to_int64() <<
    (POSITION_X_SIZE + POSITION_Z_SIZE) >>
    (POSITION_X_SIZE + POSITION_Z_SIZE)
  let z = position.z.to_int64() <<
    POSITION_X_SIZE >>
    (POSITION_X_SIZE + POSITION_Y_SIZE)
  let val = x | y | z
  buf.write_int64(val)
}
