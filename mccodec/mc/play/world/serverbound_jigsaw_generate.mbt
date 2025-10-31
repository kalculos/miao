///|
/// Jigsaw Generate packet (0x1A)
/// Generates jigsaw structure
struct JigsawGenerateC2S {
  location : @types.Position // Jigsaw block position
  levels : Int // Generation levels
  keep_jigsaws : Bool // Keep jigsaw blocks
}

///|
impl @mc.Packet for JigsawGenerateC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for JigsawGenerateC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_position(buf, self.location)
  @types.write_varint(buf, self.levels)
  @types.write_bool(buf, self.keep_jigsaws)
}

///|
impl @mc.Packet for JigsawGenerateC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let location = @types.read_position(buf);
  let levels = @types.read_varint(buf);
  let keep_jigsaws = @types.read_bool(buf);
  { location, levels, keep_jigsaws }
}

