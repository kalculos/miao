// Handshake packets for Minecraft protocol

///|
/// Intent for handshake - determines the next protocol state
pub enum HandshakeIntent {
  Status = 1    // Status ping protocol state
  Login = 2     // Login protocol state  
  Transfer = 3  // Transfer to another server
}

///|
/// Handshake packet (0x00)
/// Initial packet sent by client to initiate connection
/// This packet switches the protocol from Handshaking state to the specified next state
struct HandshakeC2S {
  protocolVersion : Int // Protocol version number (1.21.8 = 769)
  serverAddress : String // Server hostname or IP address (max 255 chars)
  serverPort : Int16 // Server port number
  intent : HandshakeIntent // Next state (1=Status, 2=Login, 3=Transfer)
}

///|
impl @mc.Packet for HandshakeC2S with clientbound(self) {
  false // Handshake is client-to-server
}