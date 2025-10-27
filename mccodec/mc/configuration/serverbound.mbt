///|
/// Client Information (configuration) packet (0x00)
/// Sent when player connects or settings change
struct ClientInformationConfigC2S {
  locale : String // e.g. "en_GB" (max 16 chars)
  view_distance : Byte // Client-side render distance in chunks
  chat_mode : Int // 0: enabled, 1: commands only, 2: hidden
  chat_colors : Bool // Whether chat colors are enabled
  displayed_skin_parts : Byte // Bit mask of displayed skin parts, unsigned, TODO: mask details and processing
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
  buf.write_byte(self.displayed_skin_parts)
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
  let displayed_skin_parts = buf.read_byte().unwrap_or(0)
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

///|
/// Cookie Response (configuration) packet (0x01)
/// Response to cookie request from server
struct CookieResponseConfigC2S {
  key : String // Cookie identifier, TODO: Identifier type
  payload : FixedArray[Byte]? // Cookie data (up to 5 kiB)
}

///|
impl @mc.Packet for CookieResponseConfigC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for CookieResponseConfigC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_string(buf, self.key)
  @types.write_optional(buf, self.payload, (b, p) => @types.write_prefix_array(
    b,
    p,
    @bytebuf.ByteWriter::write_byte,
  ))
}

///|
impl @mc.Packet for CookieResponseConfigC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let key = @types.read_string(buf)
  let payload = @types.read_optional(buf, b => @types.read_prefix_array(b, by => by
    .read_byte()
    .unwrap_or(0)))
  { key, payload }
}

///|
/// Serverbound Plugin Message (configuration) packet (0x02)
/// Mods and plugins use this to send data to server
struct ServerboundPluginMessageConfigC2S {
  channel : String // Plugin channel identifier, TODO: Identifier type
  data : Array[Byte] // Plugin data (max 32767 bytes)
}

///|
impl @mc.Packet for ServerboundPluginMessageConfigC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ServerboundPluginMessageConfigC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_string(buf, self.channel)
  buf.write_bytes(Bytes::from_array(self.data))
}

///|
impl @mc.Packet for ServerboundPluginMessageConfigC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let channel = @types.read_string(buf)
  let data = buf.read_bytes(buf.remaining()).unwrap().to_array()
  { channel, data }
}

///|
/// Acknowledge Finish Configuration packet (0x03)
/// Acknowledges server's Finish Configuration packet
struct AcknowledgeFinishConfigurationC2S {}

///|
impl @mc.Packet for AcknowledgeFinishConfigurationC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for AcknowledgeFinishConfigurationC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  // No fields to serialize
}

///|
impl @mc.Packet for AcknowledgeFinishConfigurationC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  AcknowledgeFinishConfigurationC2S::{  }
}

///|
/// Serverbound Keep Alive (configuration) packet (0x04)
/// Client response to server's keep alive
struct ServerboundKeepAliveConfigC2S {
  keep_alive_id : Int64 // Must match server's keep alive ID
}

///|
impl @mc.Packet for ServerboundKeepAliveConfigC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ServerboundKeepAliveConfigC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  buf.write_int64(self.keep_alive_id)
}

///|
impl @mc.Packet for ServerboundKeepAliveConfigC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { keep_alive_id: buf.read_int64().unwrap() }
}

///|
/// Pong (configuration) packet (0x05)
/// Response to server's ping packet
struct PongConfigC2S {
  id : Int // Must match ping ID from server
}

///|
impl @mc.Packet for PongConfigC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for PongConfigC2S with serialize(self, buf : &@bytebuf.ByteBuf) {
  buf.write_int(self.id)
}

///|
impl @mc.Packet for PongConfigC2S with deserialize(buf : &@bytebuf.ByteBuf) {
  { id: buf.read_int().unwrap() }
}

///|
/// Resource Pack Response (configuration) packet (0x06)
/// Client's response to resource pack requests
struct ResourcePackResponseConfigC2S {
  uuid : @uuid.UUID // UUID of the resource pack
  result : Int // Result ID (0-7, see protocol docs), TODO: enum
}

///|
impl @mc.Packet for ResourcePackResponseConfigC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ResourcePackResponseConfigC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_uuid(buf, self.uuid)
  @types.write_varint(buf, self.result)
}

///|
impl @mc.Packet for ResourcePackResponseConfigC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let uuid = @types.read_uuid(buf)
  let result = @types.read_varint(buf)
  { uuid, result }
}

///|
/// Serverbound Known Packs packet (0x07)
/// Informs server of which data packs client has
struct ServerboundKnownPacksC2S {
  known_packs : FixedArray[(String, String, String)] // (Namespace, ID, Version) tuples
}

///|
impl @mc.Packet for ServerboundKnownPacksC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ServerboundKnownPacksC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_prefix_array(buf, self.known_packs, (b, pack) => {
    @types.write_string(b, pack.0)
    @types.write_string(b, pack.1)
    @types.write_string(b, pack.2)
  })
}

///|
impl @mc.Packet for ServerboundKnownPacksC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let known_packs = @types.read_prefix_array(buf, b => {
    let ns = @types.read_string(b)
    let id = @types.read_string(b)
    let version = @types.read_string(b)
    (ns, id, version)
  })
  { known_packs, }
}
