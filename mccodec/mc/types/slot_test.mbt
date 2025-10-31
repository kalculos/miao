///|
test "Slot::empty - creates empty slot" {
  let slot = Slot::empty()
  assert_true(slot.is_empty())
  assert_eq(slot.item_count, 0)
  assert_eq(slot.item_id, None)
  assert_eq(slot.components_to_add, None)
  assert_eq(slot.components_to_remove, None)
}

///|
test "HashedSlot::empty - creates empty hashed slot" {
  let slot = HashedSlot::empty()
  assert_true(slot.is_empty())
  assert_eq(slot.item_count, 0)
  assert_eq(slot.item_id, None)
  assert_eq(slot.components_to_add, None)
  assert_eq(slot.components_to_remove, None)
  assert_eq(slot.hash, 0L)
}

///|
test "read_write_slot - empty slot roundtrip" {
  let buf = @bytebuf.make_unpooled(1)
  let slot = Slot::empty()
  
  write_slot(buf, slot)
  let read_slot_result = read_slot(buf)
  
  assert_true(read_slot_result.is_empty())
  assert_eq(read_slot_result.item_count, 0)
}

///|
test "read_write_slot - slot with item roundtrip" {
  let buf = @bytebuf.make_unpooled(1)
  
  // Create a simple slot with an item
  let nbt_tag = @nbt.NBTTag::Compound(Map::new())
  let component = { component_type: 1, component_data: nbt_tag }
  let slot = {
    item_count: 64,
    item_id: Some(1),
    components_to_add: Some([component]),
    components_to_remove: Some([2, 3]),
  }
  
  write_slot(buf, slot)
  let read_slot_result = read_slot(buf)
  
  assert_eq(read_slot_result.item_count, 64)
  assert_eq(read_slot_result.item_id, Some(1))
  assert_eq(read_slot_result.components_to_add.unwrap().length(), 1)
  assert_eq(read_slot_result.components_to_remove.unwrap().length(), 2)
}

///|
test "read_write_hashed_slot - empty slot roundtrip" {
  let buf = @bytebuf.make_unpooled(1)
  let slot = HashedSlot::empty()
  
  write_hashed_slot(buf, slot)
  let read_slot_result = read_hashed_slot(buf)
  
  assert_true(read_slot_result.is_empty())
  assert_eq(read_slot_result.item_count, 0)
  assert_eq(read_slot_result.hash, 0L)
}

///|
test "read_write_hashed_slot - slot with item and hash roundtrip" {
  let buf = @bytebuf.make_unpooled(1)
  
  // Create a slot with an item and hash
  let nbt_tag = @nbt.NBTTag::Compound(Map::new())
  let component = { component_type: 5, component_data: nbt_tag }
  let slot = {
    item_count: 32,
    item_id: Some(10),
    components_to_add: Some([component]),
    components_to_remove: Some([]),
    hash: 0x123456789ABCDEFL,
  }
  
  write_hashed_slot(buf, slot)
  let read_slot_result = read_hashed_slot(buf)
  
  assert_eq(read_slot_result.item_count, 32)
  assert_eq(read_slot_result.item_id, Some(10))
  assert_eq(read_slot_result.components_to_add.unwrap().length(), 1)
  assert_eq(read_slot_result.components_to_remove.unwrap().length(), 0)
  assert_eq(read_slot_result.hash, 0x123456789ABCDEFL)
}
