///|
/// Client Information (configuration) packet (0x00)
/// Sent when player connects or settings change
struct ClientInformationConfigC2S {
  locale : String // e.g. "en_GB" (max 16 chars)
  view_distance : Byte // Client-side render distance in chunks
  chat_mode : Int // 0: enabled, 1: commands only, 2: hidden
  chat_colors : Bool // Whether chat colors are enabled
  displayed_skin_parts : Array[@types.SkinPart] // List of displayed skin parts
  main_hand : Int // 0: Left, 1: Right
  enable_text_filtering : Bool // Whether text filtering is enabled
  allow_server_listings : Bool // Whether to show up in server listings
  particle_status : Int // 0: all, 1: decreased, 2: minimal
}

///|
impl @mc.Packet for ClientInformationConfigC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ClientInformationConfigC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_string(buf, self.locale)
  buf.write_byte(self.view_distance)
  @types.write_varint(buf, self.chat_mode)
  @types.write_bool(buf, self.chat_colors)
  buf.write_byte(@types.SkinPart::to_bitmask(self.displayed_skin_parts))
  @types.write_varint(buf, self.main_hand)
  @types.write_bool(buf, self.enable_text_filtering)
  @types.write_bool(buf, self.allow_server_listings)
  @types.write_varint(buf, self.particle_status)
}

///|
impl @mc.Packet for ClientInformationConfigC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let locale = @types.read_string(buf)
  let view_distance = buf.read_byte().unwrap_or(0)
  let chat_mode = @types.read_varint(buf)
  let chat_colors = @types.read_bool(buf)
  let displayed_skin_parts = @types.SkinPart::from_bitmask(
    buf.read_byte().unwrap_or(0),
  )
  let main_hand = @types.read_varint(buf)
  let enable_text_filtering = @types.read_bool(buf)
  let allow_server_listings = @types.read_bool(buf)
  let particle_status = @types.read_varint(buf)
  {
    locale,
    view_distance,
    chat_mode,
    chat_colors,
    displayed_skin_parts,
    main_hand,
    enable_text_filtering,
    allow_server_listings,
    particle_status,
  }
}
