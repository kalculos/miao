///|
/// Client Status packet (0x0B)
/// Reports client status
struct ClientStatusC2S {
  action_id : Int // Action (0=respawn, 1=request_stats), TODO: enum
}

///|
impl @mc.Packet for ClientStatusC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ClientStatusC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.action_id)
}

///|
impl @mc.Packet for ClientStatusC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  { action_id: @types.read_varint(buf) }
}

