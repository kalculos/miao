///|
/// Pickup Item packet (0x75)
/// Item pickup animation
pub(all) struct PickupItemS2C {
  collected_entity_id : Int // Collected item entity ID
  collector_entity_id : Int // Collector entity ID
  pickup_item_count : Int // Number of items picked up
}

///|
pub impl @mc.Packet for PickupItemS2C with clientbound(_) {
  true
}
