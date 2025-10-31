///|
enum SkinPart {
  CAPE
  JACKET
  LEFT_SLEEVE
  RIGHT_SLEEVE
  LEFT_PANTS_LEG
  RIGHT_PANTS_LEG
  HAT
}

///|
pub fn SkinPart::values() -> FixedArray[SkinPart] {
  FixedArray::makei(enum_to_int(SkinPart::HAT), int_to_enum)
}

///|
pub fn SkinPart::from_bitmask(mask : Byte) -> Array[SkinPart] {
  let parts = []
  for part in SkinPart::values() {
    let bit : Byte = 1 << enum_to_int(part)
    if (mask & bit) != 0 {
      parts.push(part)
    }
  }
  parts
}

///|
pub fn SkinPart::to_bitmask(parts : Array[SkinPart]) -> Byte {
  let mut mask : Byte = 0
  for part in parts {
    let bit : Byte = 1 << enum_to_int(part)
    mask = mask | bit
  }
  mask
}
