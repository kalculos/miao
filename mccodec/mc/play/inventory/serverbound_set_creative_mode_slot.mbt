///|
/// Set Creative Mode Slot packet (0x37)
/// Changes item in creative inventory slot
/// TODO: Slot type and packet (de)serialize
pub(all) struct SetCreativeModeSlotC2S {
  slot : Int16 // Slot ID
  clicked_item : String // Item data
}

