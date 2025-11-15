///|
/// Award Statistics packet (0x03)
/// Updates client-side statistics
pub(all) struct AwardStatisticsS2C {
  statistics : Array[(String, String, Int)] // (Category, Statistic, Value) entries
}

///|
pub impl @mc.Packet for AwardStatisticsS2C with clientbound(_) {
  true
}
