///|
const MINECRAFT_NAMESPACE = "minecraft"

///|
const DEFAULT_SEPARATOR = ':'

///|
struct Identifier {
  name_space : String
  path : String
} derive(Eq, Hash)

///|
pub fn Identifier::new(name_space : String, path : String) -> Identifier {
  { name_space, path }
}

///|
pub fn Identifier::from_str(s : String) -> Identifier raise {
  let parts = s.split(DEFAULT_SEPARATOR.to_string()).collect()
  match parts {
    [ns, p] => Identifier::new(ns.to_string(), p.to_string())
    [p] => Identifier::new(MINECRAFT_NAMESPACE.to_string(), p.to_string())
    _ => raise fail("Invalid identifier format: " + s)
  }
}

///|
pub fn Identifier::to_str(self : Identifier) -> String {
  if self.name_space == MINECRAFT_NAMESPACE {
    self.path
  } else {
    self.name_space + DEFAULT_SEPARATOR.to_string() + self.path
  }
}

///|
pub fn read_identifier(buf : &@bytebuf.ByteBuf) -> Identifier raise {
  let s = read_string(buf)
  Identifier::from_str(s)
}

///|
pub fn write_identifier(buf : &@bytebuf.ByteBuf, id : Identifier) -> Unit {
  let s = id.to_str()
  write_string(buf, s)
}
