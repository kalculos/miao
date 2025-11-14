///|
/// Transfer (configuration) packet (0x0B)
/// Notifies client to transfer to another server
pub(all) struct TransferConfigS2C {
  host : String // Hostname or IP of the server
  port : Int // Port of the server
}

///|
pub impl @mc.Packet for TransferConfigS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for TransferConfigS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_string(buf, self.host)
  @types.write_varint(buf, self.port)
}

///|
pub impl @mc.Packet for TransferConfigS2C with deserialize(buf : &@buffer.Buffer) {
  let host = @types.read_string(buf)
  let port = @types.read_varint(buf)
  { host, port }
}

