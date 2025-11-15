///|
/// Server Data packet (0x4F)
/// Server information data
pub(all) struct ServerDataS2C {
  motd : String // Server MOTD
  icon : Array[Byte]? // Server icon data
  enforces_secure_chat : Bool // Secure chat enforcement
}

///|
pub impl @mc.Packet for ServerDataS2C with clientbound(_) {
  true
}
