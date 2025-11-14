///|
/// Tests for AccessFlags creation
test "AccessFlags::new with no flags" {
  let flags = AccessFlags::new()
  inspect(flags.read(), content="false")
  inspect(flags.write(), content="false")
  inspect(flags.execute(), content="false")
}

///|
test "AccessFlags::new with read flag" {
  let flags = AccessFlags::new(read=true)
  inspect(flags.read(), content="true")
  inspect(flags.write(), content="false")
  inspect(flags.execute(), content="false")
}

///|
test "AccessFlags::new with write flag" {
  let flags = AccessFlags::new(write=true)
  inspect(flags.read(), content="false")
  inspect(flags.write(), content="true")
  inspect(flags.execute(), content="false")
}

///|
test "AccessFlags::new with execute flag" {
  let flags = AccessFlags::new(execute=true)
  inspect(flags.read(), content="false")
  inspect(flags.write(), content="false")
  inspect(flags.execute(), content="true")
}

///|
test "AccessFlags::new with read and write" {
  let flags = AccessFlags::new(read=true, write=true)
  inspect(flags.read(), content="true")
  inspect(flags.write(), content="true")
  inspect(flags.execute(), content="false")
}

///|
test "AccessFlags::new with all flags" {
  let flags = AccessFlags::new(read=true, write=true, execute=true)
  inspect(flags.read(), content="true")
  inspect(flags.write(), content="true")
  inspect(flags.execute(), content="true")
}

///|
test "AccessFlags::new with read and execute" {
  let flags = AccessFlags::new(read=true, execute=true)
  inspect(flags.read(), content="true")
  inspect(flags.write(), content="false")
  inspect(flags.execute(), content="true")
}

///|
test "AccessFlags::new with write and execute" {
  let flags = AccessFlags::new(write=true, execute=true)
  inspect(flags.read(), content="false")
  inspect(flags.write(), content="true")
  inspect(flags.execute(), content="true")
}
