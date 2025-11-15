///| Facade function tests

///|
/// Test open function
async test "facade open" {
  let fs = MemFileSystem::new()
  set_default_fs(fs)
  let p = path("/test.txt", using_fs=fs)
  let chan = open(p, OpenFlags::write_only(create=true), permission=0)
  let data : FixedArray[Byte] = [1, 2, 3]
  chan.write(data, 0, 3) |> ignore
  @io.Channel::close(chan)
  inspect(exists(p), content="true")
}

///|
/// Test size function
async test "facade size" {
  let fs = MemFileSystem::new()
  set_default_fs(fs)
  let p = path("/test.txt", using_fs=fs)
  let chan = open(p, OpenFlags::write_only(create=true), permission=0)
  let data : FixedArray[Byte] = [1, 2, 3, 4, 5]
  chan.write(data, 0, 5) |> ignore
  @io.Channel::close(chan)
  let s = size(p)
  inspect(s, content="5")
}

///|
/// Test attr function
async test "facade attr" {
  let fs = MemFileSystem::new()
  set_default_fs(fs)
  let p = path("/test.txt", using_fs=fs)
  let chan = open(p, OpenFlags::write_only(create=true), permission=0)
  @io.Channel::close(chan)
  let a = attr(p)
  inspect(a.kind, content="RegularFile")
  inspect(a.size, content="0")
}

///|
/// Test list_dir function
async test "facade list_dir" {
  let fs = MemFileSystem::new()
  set_default_fs(fs)
  let f1 = path("/dir/file1.txt", using_fs=fs)
  let f2 = path("/dir/file2.txt", using_fs=fs)
  @io.Channel::close(open(f1, OpenFlags::write_only(create=true), permission=0))
  @io.Channel::close(open(f2, OpenFlags::write_only(create=true), permission=0))
  let dir = path("/dir", using_fs=fs)
  let entries = list_dir(dir)
  inspect(entries.length(), content="2")
}

///|
/// Test exists function
async test "facade exists" {
  let fs = MemFileSystem::new()
  set_default_fs(fs)
  let p = path("/test.txt", using_fs=fs)
  inspect(exists(p), content="false")
  @io.Channel::close(open(p, OpenFlags::write_only(create=true), permission=0))
  inspect(exists(p), content="true")
}

///|
/// Test delete function
async test "facade delete" {
  let fs = MemFileSystem::new()
  set_default_fs(fs)
  let p = path("/test.txt", using_fs=fs)
  @io.Channel::close(open(p, OpenFlags::write_only(create=true), permission=0))
  inspect(exists(p), content="true")
  delete(p)
  inspect(exists(p), content="false")
}

///|
/// Test delete_if_exist function when exists
async test "facade delete_if_exist exists" {
  let fs = MemFileSystem::new()
  set_default_fs(fs)
  let p = path("/test.txt", using_fs=fs)
  @io.Channel::close(open(p, OpenFlags::write_only(create=true), permission=0))
  delete_if_exist(p)
  inspect(exists(p), content="false")
}

///|
/// Test delete_if_exist function when doesn't exist
async test "facade delete_if_exist not exists" {
  let fs = MemFileSystem::new()
  set_default_fs(fs)
  let p = path("/test.txt", using_fs=fs)
  delete_if_exist(p) // Should not raise
  inspect(exists(p), content="false")
}

///|
/// Test read_symbolic_link function
async test "facade read_symbolic_link" {
  let fs = MemFileSystem::new()
  set_default_fs(fs)
  let p = path("/test.txt", using_fs=fs)
  // MemFileSystem doesn't support creating symlinks yet
  // This should return None
  let link = read_symbolic_link(p)
  match link {
    Some(_) => inspect("unexpected", content="should be None")
    None => inspect(true, content="true")
  }
}
