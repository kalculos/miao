// Handshake packets for Minecraft protocol

///|
/// Intent for handshake - determines the next protocol state
pub enum HandshakeIntent {
  Status // Status ping protocol state
  Login // Login protocol state
  Transfer // Transfer to another server
}

///|
/// Handshake packet (0x00)
/// Initial packet sent by client to initiate connection
/// This packet switches the protocol from Handshaking state to the specified next state
struct HandshakeC2S {
  protocolVersion : Int // Protocol version number (1.21.8 = 769)
  serverAddress : String // Server hostname or IP address (max 255 chars)
  serverPort : UInt16 // Server port number
  intent : HandshakeIntent // Next state (1=Status, 2=Login, 3=Transfer)
}

///|
impl @mc.Packet for HandshakeC2S with clientbound(self) {
  false // Handshake is client-to-server
}

///|
impl @mc.Packet for HandshakeC2S with serialize(self, buf : &@bytebuf.ByteBuf) {
  @types.write_varint(buf, self.protocolVersion)
  @types.write_string(buf, self.serverAddress)
  buf.write_uint16(self.serverPort)
  @types.write_varint(
    buf,
    match self.intent {
      Status => 1
      Login => 2
      Transfer => 3
    },
  )
}

///|
impl @mc.Packet for HandshakeC2S with deserialize(buf : &@bytebuf.ByteBuf) {
  {
    protocolVersion: @types.read_varint(buf),
    serverAddress: @types.read_string(buf),
    serverPort: buf.read_uint16().unwrap(),
    intent: match @types.read_varint(buf) {
      1 => Status
      2 => Login
      3 => Transfer
      _ => raise fail("Invalid Handshake Intent")
    },
  }
}
