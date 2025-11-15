///| OpenFlags Tests

///|
/// Test read_only flag
test "OpenFlags::read_only" {
  let flag = OpenFlags::read_only()
  inspect(flag.is_read_only(), content="true")
  inspect(flag.has_read(), content="true")
  inspect(flag.has_write(), content="false")
  inspect(flag.is_write_only(), content="false")
  inspect(flag.is_read_write(), content="false")
  inspect(flag.is_append(), content="false")
  inspect(flag.is_create(), content="false")
  inspect(flag.is_truncate(), content="false")
  inspect(flag.is_exclusive(), content="false")
}

///|
/// Test write_only flag
test "OpenFlags::write_only basic" {
  let flag = OpenFlags::write_only()
  inspect(flag.is_write_only(), content="true")
  inspect(flag.has_write(), content="true")
  inspect(flag.has_read(), content="false")
  inspect(flag.is_read_only(), content="false")
  inspect(flag.is_read_write(), content="false")
}

///|
/// Test write_only with append
test "OpenFlags::write_only with append" {
  let flag = OpenFlags::write_only(append=true)
  inspect(flag.is_write_only(), content="true")
  inspect(flag.is_append(), content="true")
  inspect(flag.is_create(), content="false")
  inspect(flag.is_truncate(), content="false")
}

///|
/// Test write_only with create
test "OpenFlags::write_only with create" {
  let flag = OpenFlags::write_only(create=true)
  inspect(flag.is_write_only(), content="true")
  inspect(flag.is_create(), content="true")
  inspect(flag.is_exclusive(), content="false")
}

///|
/// Test write_only with truncate
test "OpenFlags::write_only with truncate" {
  let flag = OpenFlags::write_only(truncate=true)
  inspect(flag.is_write_only(), content="true")
  inspect(flag.is_truncate(), content="true")
}

///|
/// Test write_only with exclusive
test "OpenFlags::write_only with exclusive" {
  let flag = OpenFlags::write_only(create=true, exclusive=true)
  inspect(flag.is_write_only(), content="true")
  inspect(flag.is_create(), content="true")
  inspect(flag.is_exclusive(), content="true")
}

///|
/// Test read_write flag
test "OpenFlags::read_write basic" {
  let flag = OpenFlags::read_write()
  inspect(flag.is_read_write(), content="true")
  inspect(flag.has_read(), content="true")
  inspect(flag.has_write(), content="true")
  inspect(flag.is_read_only(), content="false")
  inspect(flag.is_write_only(), content="false")
}

///|
/// Test read_write with all flags
test "OpenFlags::read_write with all flags" {
  let flag = OpenFlags::read_write(
    append=true,
    create=true,
    truncate=true,
    exclusive=true,
  )
  inspect(flag.is_read_write(), content="true")
  inspect(flag.is_append(), content="true")
  inspect(flag.is_create(), content="true")
  inspect(flag.is_truncate(), content="true")
  inspect(flag.is_exclusive(), content="true")
}

///|
/// Test bit masking correctness for has_read
test "OpenFlags::has_read bit masking" {
  let read_only = OpenFlags::read_only()
  let write_only = OpenFlags::write_only()
  let read_write = OpenFlags::read_write()
  inspect(read_only.has_read(), content="true")
  inspect(write_only.has_read(), content="false")
  inspect(read_write.has_read(), content="true")
}

///|
/// Test bit masking correctness for has_write
test "OpenFlags::has_write bit masking" {
  let read_only = OpenFlags::read_only()
  let write_only = OpenFlags::write_only()
  let read_write = OpenFlags::read_write()
  inspect(read_only.has_write(), content="false")
  inspect(write_only.has_write(), content="true")
  inspect(read_write.has_write(), content="true")
}
