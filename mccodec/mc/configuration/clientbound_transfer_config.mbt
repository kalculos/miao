///|
/// Transfer (configuration) packet (0x0B)
/// Notifies client to transfer to another server
struct TransferConfigS2C {
  host : String // Hostname or IP of the server
  port : Int // Port of the server
}

///|
impl @mc.Packet for TransferConfigS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for TransferConfigS2C with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_string(buf, self.host)
  @types.write_varint(buf, self.port)
}

///|
impl @mc.Packet for TransferConfigS2C with deserialize(buf : &@bytebuf.ByteBuf) {
  let host = @types.read_string(buf)
  let port = @types.read_varint(buf)
  { host, port }
}

