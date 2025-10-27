///|
/// Stop Sound packet (0x70)
/// Stops playing sound
struct StopSoundS2C {
  flags : Byte // Stop flags
  source : Int? // Sound source (if flag set)
  sound : String? // Sound identifier (if flag set)
}
///|
impl @mc.Packet for StopSoundS2C with clientbound(self) {
  true
}