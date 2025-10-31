// Slot data types for Minecraft protocol
// https://minecraft.wiki/w/Java_Edition_protocol/Slot_data
// Based on Minecraft protocol 1.20.5+ (protocol version 765+)

///|
/// Represents a data component for an item slot
/// Component data format varies by component type
pub struct DataComponent {
  component_type : Int // VarInt - component type ID
  component_data : @nbt.NBTTag // Component data as NBT
}

///|
/// Represents an item slot in the Minecraft protocol (1.20.5+)
/// A slot can be empty (item_count = 0) or contain an item with components
pub struct Slot {
  item_count : Int // VarInt - number of items in the slot (0 = empty)
  item_id : Int? // Optional VarInt - numeric ID of the item (present if item_count > 0)
  components_to_add : FixedArray[DataComponent]? // Optional - components to add (present if item_count > 0)
  components_to_remove : FixedArray[Int]? // Optional - component IDs to remove (present if item_count > 0)
}

///|
/// Represents a hashed item slot with validation hash
/// Same as Slot but includes a hash for data integrity validation
pub struct HashedSlot {
  item_count : Int // VarInt - number of items in the slot (0 = empty)
  item_id : Int? // Optional VarInt - numeric ID of the item (present if item_count > 0)
  components_to_add : FixedArray[DataComponent]? // Optional - components to add (present if item_count > 0)
  components_to_remove : FixedArray[Int]? // Optional - component IDs to remove (present if item_count > 0)
  hash : Int64 // Long - hash for validation
}

///|
/// Creates an empty slot
pub fn Slot::empty() -> Slot {
  { item_count: 0, item_id: None, components_to_add: None, components_to_remove: None }
}

///|
/// Creates an empty hashed slot
pub fn HashedSlot::empty() -> HashedSlot {
  {
    item_count: 0,
    item_id: None,
    components_to_add: None,
    components_to_remove: None,
    hash: 0L,
  }
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
/// Read a data component from the buffer
fn read_data_component(buf : &@bytebuf.ByteBuf) -> DataComponent raise {
  let component_type = read_varint(buf)
  let component_data = read_nbt(buf)
  { component_type, component_data }
}

///|
/// Write a data component to the buffer
fn write_data_component(
  buf : &@bytebuf.ByteBuf,
  component : DataComponent
) -> Unit raise {
  write_varint(buf, component.component_type)
  write_nbt(buf, component.component_data)
}

///|
/// Read a slot from the buffer
pub fn read_slot(buf : &@bytebuf.ByteBuf) -> Slot raise {
  let item_count = read_varint(buf)
  if item_count <= 0 {
    return Slot::empty()
  }
  let item_id = read_varint(buf)
  let components_to_add = read_prefix_array(buf, read_data_component)
  let components_to_remove = read_prefix_array(buf, read_varint)
  {
    item_count,
    item_id: Some(item_id),
    components_to_add: Some(components_to_add),
    components_to_remove: Some(components_to_remove),
  }
}

///|
/// Write a slot to the buffer
pub fn write_slot(buf : &@bytebuf.ByteBuf, slot : Slot) -> Unit raise {
  write_varint(buf, slot.item_count)
  if slot.item_count > 0 {
    match slot.item_id {
      Some(id) => write_varint(buf, id)
      None => raise fail("Slot has items but no item_id")
    }
    match slot.components_to_add {
      Some(components) =>
        write_prefix_array(buf, components, write_data_component)
      None => write_varint(buf, 0) // No components to add
    }
    match slot.components_to_remove {
      Some(components) => write_prefix_array(buf, components, write_varint)
      None => write_varint(buf, 0) // No components to remove
    }
  }
}

///|
/// Read a hashed slot from the buffer
pub fn read_hashed_slot(buf : &@bytebuf.ByteBuf) -> HashedSlot raise {
  let item_count = read_varint(buf)
  if item_count <= 0 {
    let hash = buf.read_int64().unwrap_or(0L)
    return { ..HashedSlot::empty(), hash }
  }
  let item_id = read_varint(buf)
  let components_to_add = read_prefix_array(buf, read_data_component)
  let components_to_remove = read_prefix_array(buf, read_varint)
  let hash = buf.read_int64().unwrap_or(0L)
  {
    item_count,
    item_id: Some(item_id),
    components_to_add: Some(components_to_add),
    components_to_remove: Some(components_to_remove),
    hash,
  }
}

///|
/// Write a hashed slot to the buffer
pub fn write_hashed_slot(
  buf : &@bytebuf.ByteBuf,
  slot : HashedSlot
) -> Unit raise {
  write_varint(buf, slot.item_count)
  if slot.item_count > 0 {
    match slot.item_id {
      Some(id) => write_varint(buf, id)
      None => raise fail("Slot has items but no item_id")
    }
    match slot.components_to_add {
      Some(components) =>
        write_prefix_array(buf, components, write_data_component)
      None => write_varint(buf, 0) // No components to add
    }
    match slot.components_to_remove {
      Some(components) => write_prefix_array(buf, components, write_varint)
      None => write_varint(buf, 0) // No components to remove
    }
  }
  buf.write_int64(slot.hash)
}
