///|
/// A channel corresponds to an I/O resources whose lifecycle is explicitly managed by the user and guarantees
/// the full duplex access, which made it convenient for handling network protocol as a layer.
/// While Channel is mainly for communication, it also takes the responsibility to provide associated informations(e.g Addr)
/// to users.
pub(open) trait Channel: Reader + Writer {
  async close(Self) -> Unit
}