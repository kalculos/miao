///|
/// Transfer (play) packet (0x7A)
/// Transfers to another server
pub(all) struct TransferPlayS2C {
  host : String // Target server host
  port : Int // Target server port
}

///|
pub impl @mc.Packet for TransferPlayS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for TransferPlayS2C with serialize(self, buf : &@buffer.Buffer) raise {
  @types.write_string(buf, self.host)
  @types.write_varint(buf, self.port)
}

///|
pub impl @mc.Packet for TransferPlayS2C with deserialize(buf : &@buffer.Buffer) raise {
  let host = @types.read_string(buf)
  let port = @types.read_varint(buf)
  { host, port }
}
