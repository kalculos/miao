///|
struct KnownPack {
  name_space : String // Packet namespace
  name : String // Packet name
  version : String // Packet version
}

///|
pub fn read_known_pack(buf : &@buffer.Buffer) -> KnownPack raise {
  let name_space = read_string(buf)
  let name = read_string(buf)
  let version = read_string(buf)
  { name_space, name, version }
}

///|
pub fn write_known_pack(buf : &@buffer.Buffer, packet : KnownPack) -> Unit {
  write_string(buf, packet.name_space)
  write_string(buf, packet.name)
  write_string(buf, packet.version)
}
