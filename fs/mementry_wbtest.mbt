///|
/// Test time instant
test "time instant" {
  let now = @time.Instant::now()
  ignore(now)
}

///|
/// Test MemEntry creation
test "mementry creation" {
  let now = @time.Instant::now()
  let entry : MemEntry = {
    name: "test",
    kind: FileKind::RegularFile,
    content: [],
    children: Map::new(),
    target: None,
    last_modified: now,
    last_access: now,
    creation_time: now,
  }
  inspect(entry.name, content="test")
}

///|
/// Test MemFileSystem creation
test "memfilesystem new" {
  let fs = MemFileSystem::new()
  ignore(fs)
}

///|
/// Test find_ref
test "find_ref root" {
  let fs = MemFileSystem::new()
  let p = path("/", using_fs=fs)
  match fs.find_ref(p) {
    Some(r) => inspect(r.val.kind, content="Directory")
    None => assert_false(true, msg="ERROR: Root not found!")
  }
}

///|
/// Test find
test "find root" {
  let fs = MemFileSystem::new()
  let p = path("/", using_fs=fs)
  match fs.find(p) {
    Some(entry) => inspect(entry.kind, content="Directory")
    None => assert_false(true, msg="ERROR: Root not found!")
  }
}

///|
/// Async test
async test "async memfilesystem" {
  let fs = MemFileSystem::new()
  set_default_fs(fs)
}
