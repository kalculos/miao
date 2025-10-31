///|
/// Client Information (play) packet (0x0D)
/// Updates client settings
struct ClientInformationPlayC2S {
  locale : String // Locale (e.g. "en_us")
  view_distance : Byte // Render distance
  chat_mode : Int // Chat visibility enum(0=enabled, 1=commands_only, 2=hidden)
  chat_colors : Bool // Chat colors enabled
  displayed_skin_parts : Array[@types.SkinPart] // Skin parts displayed
  main_hand : Int // Main hand enum(0=left, 1=right)
  enable_text_filtering : Bool // Text filtering
  allow_server_listings : Bool // Server listings
  particle_status : Int // Particle level enum(0=all, 1=decreased, 2=minimal)
}

///|
impl @mc.Packet for ClientInformationPlayC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ClientInformationPlayC2S with serialize(
  self,
  buf : &@buffer.Buffer,
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
impl @mc.Packet for ClientInformationPlayC2S with deserialize(
  buf : &@buffer.Buffer,
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
