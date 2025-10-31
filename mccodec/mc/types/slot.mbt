// Slot data types for Minecraft protocol
// https://minecraft.wiki/w/Java_Edition_protocol/Slot_data
// Based on Minecraft protocol 1.20.5+ (protocol version 765+)

///|
/// Represents an item slot in the Minecraft protocol (1.20.5+)
/// A slot can be empty (item_count = 0) or contain an item with components
pub struct Slot {
  item_count : Int // VarInt - number of items in the slot (0 = empty)
  item_id : Int? // Optional VarInt - numeric ID of the item (present if item_count > 0)
  components : Map[Int, @nbt.NBTTag?] // All components (both to add and remove), empty if item_count = 0, None for components to remove
}

///|
/// Represents a hashed item slot with validation hash
/// Same as Slot but includes a hash for data integrity validation
pub struct HashedSlot {
  item_count : Int // VarInt - number of items in the slot (0 = empty)
  item_id : Int? // Optional VarInt - numeric ID of the item (present if item_count > 0)
  components : Map[Int, Int?] // All components (both to add and remove), empty if item_count = 0, None for components to remove
}

///|
/// Creates an empty slot
pub fn Slot::empty() -> Slot {
  { item_count: 0, item_id: None, components: Map::new() }
}

///|
/// Creates an empty hashed slot
pub fn HashedSlot::empty() -> HashedSlot {
  { item_count: 0, item_id: None, components: Map::new() }
}

///|
/// Checks if a slot is empty
pub fn Slot::is_empty(self : Slot) -> Bool {
  self.item_count == 0
}

///|
/// Checks if a hashed slot is empty
pub fn HashedSlot::is_empty(self : HashedSlot) -> Bool {
  self.item_count == 0
}

///|
/// Read a slot from the buffer
pub fn read_slot(buf : &@buffer.Buffer) -> Slot raise {
  let item_count = read_varint(buf)
  if item_count <= 0 {
    return Slot::empty()
  }
  let item_id = read_varint(buf)
  let length_to_add = read_varint(buf)
  let length_to_remove = read_varint(buf)
  let components : Map[Int, @nbt.NBTTag?] = Map::new()
  for index = 0; index < length_to_add; index = index + 1 {
    let component = read_nbt(buf)
    components.set(index, Some(component))
  }
  for index = 0; index < length_to_remove; index = index + 1 {
    components.set(read_varint(buf), None)
  }
  { item_count, item_id: Some(item_id), components }
}

///|
/// Write a slot to the buffer
pub fn write_slot(buf : &@buffer.Buffer, slot : Slot) -> Unit raise {
  write_varint(buf, slot.item_count)
  if slot.item_count > 0 {
    guard slot.item_id is Some(id) else {
      raise fail("Slot has items but no item_id")
    }
    write_varint(buf, id)
    let mut length_to_add = 0
    let mut length_to_remove = 0
    for _, component_data in slot.components {
      if component_data is Some(_) {
        length_to_add = length_to_add + 1
      } else {
        length_to_remove = length_to_remove + 1
      }
    }
    write_varint(buf, length_to_add)
    write_varint(buf, length_to_remove)
    for component_id, component_data in slot.components {
      if component_data is Some(data) {
        write_varint(buf, component_id)
        write_nbt(buf, data)
      }
    }
    for component_id, component_data in slot.components {
      if component_data is None {
        write_varint(buf, component_id)
      }
    }
  }
}

///|
/// Read a hashed slot from the buffer
pub fn read_hashed_slot(buf : &@buffer.Buffer) -> HashedSlot raise {
  let item_count = read_varint(buf)
  if item_count <= 0 {
    return HashedSlot::empty()
  }
  let item_id = read_varint(buf)
  let components = Map::new()
  let length_to_add = read_varint(buf)
  for i = 0; i < length_to_add; i = i + 1 {
    components.set(read_varint(buf), Some(read_varint(buf)))
  }
  let length_to_remove = read_varint(buf)
  for i = 0; i < length_to_remove; i = i + 1 {
    components.set(read_varint(buf), None)
  }
  { item_count, item_id: Some(item_id), components }
}

///|
/// Write a hashed slot to the buffer
pub fn write_hashed_slot(
  buf : &@buffer.Buffer,
  slot : HashedSlot,
) -> Unit raise {
  write_varint(buf, slot.item_count)
  if slot.item_count > 0 {
    guard slot.item_id is Some(id) else {
      raise fail("Slot has items but no item_id")
    }
    write_varint(buf, id)
    let mut length_to_add = 0
    let mut length_to_remove = 0
    for _, component_data in slot.components {
      if component_data is Some(_) {
        length_to_add = length_to_add + 1
      } else {
        length_to_remove = length_to_remove + 1
      }
    }
    write_varint(buf, length_to_add)
    for component_id, component_data in slot.components {
      if component_data is Some(data) {
        write_varint(buf, component_id)
        write_varint(buf, data)
      }
    }
    write_varint(buf, length_to_remove)
    for component_id, component_data in slot.components {
      if component_data is None {
        write_varint(buf, component_id)
      }
    }
  }
}
