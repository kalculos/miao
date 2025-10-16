struct PacketFamily {
  packetVersion: Int
  idMapping: Map[Int, PacketType]
}

enum PacketStage {
  Handshake
  Login
  Config
  Play
}

pub struct PacketType {
  packetId: Int
  clientbound: Bool
  stage: PacketStage
  reader: (&@net.Connection) -> Pkt
  writer: (Pkt, &@net.Connection)  -> Unit
}

pub struct MinecraftPacket(Pkt, PacketType)

pub enum Pkt {
  HandshakeC2S(HandshakeC2S)
}


///
/// 

fn create_1_21_8_family() -> PacketFamily {
  return PacketFamily::{
    packetVersion: J1_21_8,
    idMapping: {
      0x00: PacketType::{
        packetId: 0x00,
        clientbound: false,
        stage: Handshake,
        reader: read_handshake_c2s,
        writer: write_handshake_c2s
      }
    }
  }
}

fn read_handshake_c2s(conn: &@net.Connection) -> Pkt {
  ...
}

fn write_handshake_c2s(pkt: Pkt, conn: &@net.Connection) -> Unit {
  ...
}
