///|
/// Login Acknowledged packet (0x03)
/// Acknowledges Login Success, switches to configuration state
struct LoginAcknowledgedC2S {}

///|
impl @mc.Packet for LoginAcknowledgedC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for LoginAcknowledgedC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  // No fields to serialize
}

///|
impl @mc.Packet for LoginAcknowledgedC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  LoginAcknowledgedC2S::{  } // No fields to deserialize
}
