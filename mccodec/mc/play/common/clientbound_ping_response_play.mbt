///|
/// Ping Response (play) packet (0x37)
/// Server ping response
pub(all) struct PingResponsePlayS2C {
  payload : Int64 // Ping payload
}

///|
pub impl @mc.Packet for PingResponsePlayS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for PingResponsePlayS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) raise {
  buf.write_int64(self.payload)
}

///|
pub impl @mc.Packet for PingResponsePlayS2C with deserialize(buf : &@buffer.Buffer) raise {
  let payload = buf.read_int64()
  { payload, }
}
