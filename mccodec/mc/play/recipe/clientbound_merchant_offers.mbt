///|
/// Merchant Offers packet (0x2D)
/// Updates merchant trading interface
struct MerchantOffersS2C {
  window_id : Int // Window ID
  trades : Array[String] // Trade offer data
  villager_level : Int // Villager level
  experience : Int // Villager experience
  is_regular_villager : Bool // Regular villager flag
  can_restock : Bool // Can restock trades
}
///|
impl @mc.Packet for MerchantOffersS2C with clientbound(self) {
  true
}