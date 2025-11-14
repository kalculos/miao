///|
/// Tests for OpenFlags::read_only
test "OpenFlags::read_only creates read-only flags" {
  let flags = OpenFlags::read_only()
  inspect(flags.is_read_only(), content="true")
  inspect(flags.is_write_only(), content="false")
  inspect(flags.is_read_write(), content="false")
  inspect(flags.has_read(), content="true")
  inspect(flags.has_write(), content="false")
}

///|
/// Tests for OpenFlags::write_only
test "OpenFlags::write_only with no options" {
  let flags = OpenFlags::write_only()
  inspect(flags.is_write_only(), content="true")
  inspect(flags.is_read_only(), content="false")
  inspect(flags.is_read_write(), content="false")
  inspect(flags.has_write(), content="true")
  inspect(flags.has_read(), content="false")
  inspect(flags.is_append(), content="false")
  inspect(flags.is_create(), content="false")
  inspect(flags.is_truncate(), content="false")
  inspect(flags.is_exclusive(), content="false")
}

///|
test "OpenFlags::write_only with append" {
  let flags = OpenFlags::write_only(append=true)
  inspect(flags.is_write_only(), content="true")
  inspect(flags.is_append(), content="true")
  inspect(flags.is_create(), content="false")
  inspect(flags.is_truncate(), content="false")
  inspect(flags.is_exclusive(), content="false")
}

///|
test "OpenFlags::write_only with create" {
  let flags = OpenFlags::write_only(create=true)
  inspect(flags.is_write_only(), content="true")
  inspect(flags.is_create(), content="true")
  inspect(flags.is_append(), content="false")
  inspect(flags.is_truncate(), content="false")
  inspect(flags.is_exclusive(), content="false")
}

///|
test "OpenFlags::write_only with truncate" {
  let flags = OpenFlags::write_only(truncate=true)
  inspect(flags.is_write_only(), content="true")
  inspect(flags.is_truncate(), content="true")
  inspect(flags.is_append(), content="false")
  inspect(flags.is_create(), content="false")
  inspect(flags.is_exclusive(), content="false")
}

///|
test "OpenFlags::write_only with exclusive" {
  let flags = OpenFlags::write_only(exclusive=true)
  inspect(flags.is_write_only(), content="true")
  inspect(flags.is_exclusive(), content="true")
  inspect(flags.is_append(), content="false")
  inspect(flags.is_create(), content="false")
  inspect(flags.is_truncate(), content="false")
}

///|
test "OpenFlags::write_only with multiple options" {
  let flags = OpenFlags::write_only(append=true, create=true)
  inspect(flags.is_write_only(), content="true")
  inspect(flags.is_append(), content="true")
  inspect(flags.is_create(), content="true")
  inspect(flags.is_truncate(), content="false")
  inspect(flags.is_exclusive(), content="false")
}

///|
test "OpenFlags::write_only with all options" {
  let flags = OpenFlags::write_only(append=true, create=true, truncate=true, exclusive=true)
  inspect(flags.is_write_only(), content="true")
  inspect(flags.is_append(), content="true")
  inspect(flags.is_create(), content="true")
  inspect(flags.is_truncate(), content="true")
  inspect(flags.is_exclusive(), content="true")
}

///|
/// Tests for OpenFlags::read_write
test "OpenFlags::read_write with no options" {
  let flags = OpenFlags::read_write()
  inspect(flags.is_read_write(), content="true")
  inspect(flags.is_read_only(), content="false")
  inspect(flags.is_write_only(), content="false")
  inspect(flags.has_read(), content="true")
  inspect(flags.has_write(), content="true")
  inspect(flags.is_append(), content="false")
  inspect(flags.is_create(), content="false")
  inspect(flags.is_truncate(), content="false")
  inspect(flags.is_exclusive(), content="false")
}

///|
test "OpenFlags::read_write with append" {
  let flags = OpenFlags::read_write(append=true)
  inspect(flags.is_read_write(), content="true")
  inspect(flags.is_append(), content="true")
  inspect(flags.is_create(), content="false")
  inspect(flags.is_truncate(), content="false")
  inspect(flags.is_exclusive(), content="false")
}

///|
test "OpenFlags::read_write with create" {
  let flags = OpenFlags::read_write(create=true)
  inspect(flags.is_read_write(), content="true")
  inspect(flags.is_create(), content="true")
  inspect(flags.is_append(), content="false")
  inspect(flags.is_truncate(), content="false")
  inspect(flags.is_exclusive(), content="false")
}

///|
test "OpenFlags::read_write with truncate" {
  let flags = OpenFlags::read_write(truncate=true)
  inspect(flags.is_read_write(), content="true")
  inspect(flags.is_truncate(), content="true")
  inspect(flags.is_append(), content="false")
  inspect(flags.is_create(), content="false")
  inspect(flags.is_exclusive(), content="false")
}

///|
test "OpenFlags::read_write with exclusive" {
  let flags = OpenFlags::read_write(exclusive=true)
  inspect(flags.is_read_write(), content="true")
  inspect(flags.is_exclusive(), content="true")
  inspect(flags.is_append(), content="false")
  inspect(flags.is_create(), content="false")
  inspect(flags.is_truncate(), content="false")
}

///|
test "OpenFlags::read_write with multiple options" {
  let flags = OpenFlags::read_write(create=true, truncate=true)
  inspect(flags.is_read_write(), content="true")
  inspect(flags.is_create(), content="true")
  inspect(flags.is_truncate(), content="true")
  inspect(flags.is_append(), content="false")
  inspect(flags.is_exclusive(), content="false")
}

///|
test "OpenFlags::read_write with all options" {
  let flags = OpenFlags::read_write(append=true, create=true, truncate=true, exclusive=true)
  inspect(flags.is_read_write(), content="true")
  inspect(flags.is_append(), content="true")
  inspect(flags.is_create(), content="true")
  inspect(flags.is_truncate(), content="true")
  inspect(flags.is_exclusive(), content="true")
}

///|
/// Tests for flag combinations
test "OpenFlags different modes are mutually exclusive" {
  let read = OpenFlags::read_only()
  let write = OpenFlags::write_only()
  let rw = OpenFlags::read_write()
  
  // read_only should not be write_only or read_write
  inspect(read.is_read_only(), content="true")
  inspect(read.is_write_only(), content="false")
  inspect(read.is_read_write(), content="false")
  
  // write_only should not be read_only or read_write
  inspect(write.is_write_only(), content="true")
  inspect(write.is_read_only(), content="false")
  inspect(write.is_read_write(), content="false")
  
  // read_write should not be read_only or write_only
  inspect(rw.is_read_write(), content="true")
  inspect(rw.is_read_only(), content="false")
  inspect(rw.is_write_only(), content="false")
}
