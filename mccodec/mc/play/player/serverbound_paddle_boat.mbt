///|
/// Paddle Boat packet (0x22)
/// Controls boat paddles
struct PaddleBoatC2S {
  left_paddle_turning : Bool // Left paddle state
  right_paddle_turning : Bool // Right paddle state
}

///|
impl @mc.Packet for PaddleBoatC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for PaddleBoatC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_bool(buf, self.left_paddle_turning)
  @types.write_bool(buf, self.right_paddle_turning)
}

///|
impl @mc.Packet for PaddleBoatC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let left_paddle_turning = @types.read_bool(buf)
  let right_paddle_turning = @types.read_bool(buf)
  { left_paddle_turning, right_paddle_turning }
}

