pub enum HandshakeIntent {
  Status = 1
  Login = 2
  Transfer = 3
}

///|
struct HandshakeC2S {
  protocolVersion : Int
  serverAddress : String
  serverPort : Int16
  intent : HandshakeIntent
}

impl Packet for HandshakeC2S with clientbound(self) {
  true
}