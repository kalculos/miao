///|
/// Custom Report Details (configuration) packet (0x0F)
/// Contains crash/disconnection report details
struct CustomReportDetailsConfigS2C {
  details : Map[String, String] // (Title, Description) pairs (max 32 entries), prehaps we should add a type for Report Detail
}

///|
impl @mc.Packet for CustomReportDetailsConfigS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for CustomReportDetailsConfigS2C with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_map(buf, self.details, @types.write_string, @types.write_string)
}

///|
impl @mc.Packet for CustomReportDetailsConfigS2C with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let details = @types.read_map(buf, @types.read_string, @types.read_string)
  { details, }
}
