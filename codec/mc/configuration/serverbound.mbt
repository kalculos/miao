///|
/// Client Information (configuration) packet (0x00)
/// Sent when player connects or settings change
struct ClientInformationConfigC2S {
  locale : String // e.g. "en_GB" (max 16 chars)
  view_distance : Byte // Client-side render distance in chunks
  chat_mode : Int // 0: enabled, 1: commands only, 2: hidden
  chat_colors : Bool // Whether chat colors are enabled
  displayed_skin_parts : Byte // Bit mask of displayed skin parts
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
/// Cookie Response (configuration) packet (0x01)
/// Response to cookie request from server
struct CookieResponseConfigC2S {
  key : String // Cookie identifier
  payload : Array[Byte]? // Cookie data (up to 5 kiB)
}

///|
impl @mc.Packet for CookieResponseConfigC2S with clientbound(self) {
  false
}

///|
/// Serverbound Plugin Message (configuration) packet (0x02)
/// Mods and plugins use this to send data to server
struct ServerboundPluginMessageConfigC2S {
  channel : String // Plugin channel identifier
  data : Array[Byte] // Plugin data (max 32767 bytes)
}

///|
impl @mc.Packet for ServerboundPluginMessageConfigC2S with clientbound(self) {
  false
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
/// Resource Pack Response (configuration) packet (0x06)
/// Client's response to resource pack requests
struct ResourcePackResponseConfigC2S {
  uuid : String // UUID of the resource pack
  result : Int // Result ID (0-7, see protocol docs)
}

///|
impl @mc.Packet for ResourcePackResponseConfigC2S with clientbound(self) {
  false
}

///|
/// Serverbound Known Packs packet (0x07)
/// Informs server of which data packs client has
struct ServerboundKnownPacksC2S {
  known_packs : Array[(String, String, String)] // (Namespace, ID, Version) tuples
}

///|
impl @mc.Packet for ServerboundKnownPacksC2S with clientbound(self) {
  false
}
