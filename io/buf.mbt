///|
pub struct ByteBufReader {
  buffer : &@bytebuf.ByteBuf
  priv mut closed : Bool
}

///|
pub fn ByteBufReader::new(buf : &@bytebuf.ByteBuf) -> ByteBufReader {
  { buffer: buf, closed: false }
}

///|
pub(all) struct ByteBufWriter {
  buffer : &@bytebuf.ByteBuf
  priv mut closed : Bool
}

///|
pub fn ByteBufWriter::new(buf : &@bytebuf.ByteBuf) -> ByteBufWriter {
  ByteBufWriter::{ buffer: buf, closed: false }
}
