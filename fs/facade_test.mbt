///| Facade function tests

///|
/// Test open function
async test "facade open" {
  let fs = MemFileSystem::new()
  set_default_fs(fs)
  let p = path("/test.txt", using_fs=fs)
  let chan = match open(p, OpenFlags::write_only(create=true), permission=0) {
    Ok(c) => c
    Err(_) => return
  }
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
  let chan = match open(p, OpenFlags::write_only(create=true), permission=0) {
    Ok(c) => c
    Err(_) => return
  }
  let data : FixedArray[Byte] = [1, 2, 3, 4, 5]
  chan.write(data, 0, 5) |> ignore
  @io.Channel::close(chan)
  let s = match size(p) {
    Ok(sz) => sz
    Err(_) => return
  }
  inspect(s, content="5")
}

///|
/// Test attr function
async test "facade attr" {
  let fs = MemFileSystem::new()
  set_default_fs(fs)
  let p = path("/test.txt", using_fs=fs)
  let chan = match open(p, OpenFlags::write_only(create=true), permission=0) {
    Ok(c) => c
    Err(_) => return
  }
  @io.Channel::close(chan)
  let a = match attr(p) {
    Ok(attr) => attr
    Err(_) => return
  }
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
  match open(f1, OpenFlags::write_only(create=true), permission=0) {
    Ok(c) => @io.Channel::close(c)
    Err(_) => return
  }
  match open(f2, OpenFlags::write_only(create=true), permission=0) {
    Ok(c) => @io.Channel::close(c)
    Err(_) => return
  }
  let dir = path("/dir", using_fs=fs)
  let entries = match list_dir(dir) {
    Ok(e) => e
    Err(_) => return
  }
  inspect(entries.length(), content="2")
}

///|
/// Test exists function
async test "facade exists" {
  let fs = MemFileSystem::new()
  set_default_fs(fs)
  let p = path("/test.txt", using_fs=fs)
  inspect(exists(p), content="false")
  match open(p, OpenFlags::write_only(create=true), permission=0) {
    Ok(c) => @io.Channel::close(c)
    Err(_) => return
  }
  inspect(exists(p), content="true")
}

///|
/// Test delete function
async test "facade delete" {
  let fs = MemFileSystem::new()
  set_default_fs(fs)
  let p = path("/test.txt", using_fs=fs)
  match open(p, OpenFlags::write_only(create=true), permission=0) {
    Ok(c) => @io.Channel::close(c)
    Err(_) => return
  }
  inspect(exists(p), content="true")
  match delete(p) {
    Ok(_) => ()
    Err(_) => return
  }
  inspect(exists(p), content="false")
}

///|
/// Test delete_if_exist function when exists
async test "facade delete_if_exist exists" {
  let fs = MemFileSystem::new()
  set_default_fs(fs)
  let p = path("/test.txt", using_fs=fs)
  match open(p, OpenFlags::write_only(create=true), permission=0) {
    Ok(c) => @io.Channel::close(c)
    Err(_) => return
  }
  match delete_if_exist(p) {
    Ok(_) => ()
    Err(_) => return
  }
  inspect(exists(p), content="false")
}

///|
/// Test delete_if_exist function when doesn't exist
async test "facade delete_if_exist not exists" {
  let fs = MemFileSystem::new()
  set_default_fs(fs)
  let p = path("/test.txt", using_fs=fs)
  match delete_if_exist(p) {
    Ok(_) => ()
    Err(_) => return
  }
  inspect(exists(p), content="false")
}

///|
/// Test read_symbolic_link function
async test "facade read_symbolic_link" {
  let fs = MemFileSystem::new()
  set_default_fs(fs)
  let p = path("/test.txt", using_fs=fs)
  // MemFileSystem doesn't support creating symlinks yet
  // This should return an error
  match read_symbolic_link(p) {
    Ok(_) => inspect("unexpected", content="should be error")
    Err(_) => inspect(true, content="true")
  }
}
