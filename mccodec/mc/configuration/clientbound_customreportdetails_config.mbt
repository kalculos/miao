///|
/// Custom Report Details (configuration) packet (0x0F)
/// Contains crash/disconnection report details
struct CustomReportDetailsConfigS2C {
  details : FixedArray[(String, String)] // (Title, Description) pairs (max 32 entries), prehaps we should add a type for Report Detail
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
  @types.write_prefix_array(buf, self.details, (b, detail) => {
    @types.write_string(b, detail.0)
    @types.write_string(b, detail.1)
  })
}

///|
impl @mc.Packet for CustomReportDetailsConfigS2C with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let details = @types.read_prefix_array(buf, b => {
    let title = @types.read_string(b)
    let description = @types.read_string(b)
    (title, description)
  })
  { details, }
}

