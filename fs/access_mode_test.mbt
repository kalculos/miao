///| AccessFlags Tests

///|
/// Test AccessFlags::new with no flags
test "AccessFlags::new empty" {
  let flags = AccessFlags::new()
  inspect(flags.read(), content="false")
  inspect(flags.write(), content="false")
  inspect(flags.execute(), content="false")
}

///|
/// Test AccessFlags::new with read
test "AccessFlags::new read" {
  let flags = AccessFlags::new(read=true)
  inspect(flags.read(), content="true")
  inspect(flags.write(), content="false")
  inspect(flags.execute(), content="false")
}

///|
/// Test AccessFlags::new with write
test "AccessFlags::new write" {
  let flags = AccessFlags::new(write=true)
  inspect(flags.read(), content="false")
  inspect(flags.write(), content="true")
  inspect(flags.execute(), content="false")
}

///|
/// Test AccessFlags::new with execute
test "AccessFlags::new execute" {
  let flags = AccessFlags::new(execute=true)
  inspect(flags.read(), content="false")
  inspect(flags.write(), content="false")
  inspect(flags.execute(), content="true")
}

///|
/// Test AccessFlags::new with all flags
test "AccessFlags::new all" {
  let flags = AccessFlags::new(read=true, write=true, execute=true)
  inspect(flags.read(), content="true")
  inspect(flags.write(), content="true")
  inspect(flags.execute(), content="true")
}

///|
/// Test AccessFlags::new with read and write
test "AccessFlags::new read and write" {
  let flags = AccessFlags::new(read=true, write=true)
  inspect(flags.read(), content="true")
  inspect(flags.write(), content="true")
  inspect(flags.execute(), content="false")
}
