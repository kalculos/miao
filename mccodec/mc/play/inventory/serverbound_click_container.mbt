///|
/// Click Container packet (0x11)
/// Clicks container slot
/// TODO: slots type and packet (de)serialize
struct ClickContainerC2S {
  window_id : Int // Window ID
  state_id : Int // State ID
  slot : Int16 // Clicked slot
  button : Byte // Mouse button
  mode : Int // Click mode enum
  changed_slots : FixedArray[(Int16, String)] // Changed slot data
  carried_item : String // Carried item data
}

///|
impl @mc.Packet for ClickContainerC2S with clientbound(self) {
  false
}

