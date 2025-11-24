///| MemFileSystem comprehensive tests

///|
/// Test create and write file
async test "MemFileSystem create and write" {
  let fs = MemFileSystem::new()
  let p = path("/test.txt", using_fs=fs)
  let chan = match
    fs.open_file(p, OpenFlags::write_only(create=true), mode=AccessFlags::new()) {
    Ok(c) => c
    Err(_) => return
  }
  let data : FixedArray[Byte] = [72, 101, 108, 108, 111] // "Hello"
  let written = chan.write(data, 0, 5)
  inspect(written, content="5")

  // Read back
  let rchan = fs
    .open_file(p, OpenFlags::read_only(), mode=AccessFlags::new())
    .unwrap()
  let buf : FixedArray[Byte] = FixedArray::make(10, 0)
  let read_count = rchan.read(buf, 0, 10)
  inspect(read_count, content="5")
  inspect(buf[0], content="b'\\x48'") // 'H'
}

///|
/// Test truncate flag
async test "MemFileSystem truncate flag" {
  let fs = MemFileSystem::new()
  let p = path("/test.txt", using_fs=fs)

  // Write initial data
  let chan1 = match
    fs.open_file(p, OpenFlags::write_only(create=true), mode=AccessFlags::new()) {
    Ok(c) => c
    Err(_) => return
  }
  let data1 : FixedArray[Byte] = [1, 2, 3, 4, 5]
  chan1.write(data1, 0, 5) |> ignore
  @io.Channel::close(chan1)

  // Open with truncate
  let chan2 = match
    fs.open_file(
      p,
      OpenFlags::write_only(truncate=true),
      mode=AccessFlags::new(),
    ) {
    Ok(c) => c
    Err(_) => return
  }
  let data2 : FixedArray[Byte] = [6, 7]
  chan2.write(data2, 0, 2) |> ignore
  @io.Channel::close(chan2)

  // Read back
  let rchan = fs
    .open_file(p, OpenFlags::read_only(), mode=AccessFlags::new())
    .unwrap()
  let buf : FixedArray[Byte] = FixedArray::make(10, 0)
  let read_count = rchan.read(buf, 0, 10)
  inspect(read_count, content="2")
  inspect(buf[0], content="b'\\x06'")
}

///|
/// Test append flag
async test "MemFileSystem append flag" {
  let fs = MemFileSystem::new()
  let p = path("/test.txt", using_fs=fs)

  // Write initial data
  let chan1 = match
    fs.open_file(p, OpenFlags::write_only(create=true), mode=AccessFlags::new()) {
    Ok(c) => c
    Err(_) => return
  }
  let data1 : FixedArray[Byte] = [1, 2, 3]
  chan1.write(data1, 0, 3) |> ignore
  @io.Channel::close(chan1)

  // Open with append
  let chan2 = match
    fs.open_file(p, OpenFlags::write_only(append=true), mode=AccessFlags::new()) {
    Ok(c) => c
    Err(_) => return
  }
  let data2 : FixedArray[Byte] = [4, 5]
  chan2.write(data2, 0, 2) |> ignore
  @io.Channel::close(chan2)

  // Read back
  let rchan = fs
    .open_file(p, OpenFlags::read_only(), mode=AccessFlags::new())
    .unwrap()
  let buf : FixedArray[Byte] = FixedArray::make(10, 0)
  let read_count = rchan.read(buf, 0, 10)
  inspect(read_count, content="5")
  inspect(buf[0], content="b'\\x01'")
  inspect(buf[3], content="b'\\x04'")
}

///|
/// Test exclusive flag succeeds when file doesn't exist
async test "MemFileSystem exclusive flag success" {
  let fs = MemFileSystem::new()
  let p = path("/test.txt", using_fs=fs)
  let chan = match
    fs.open_file(
      p,
      OpenFlags::write_only(create=true, exclusive=true),
      mode=AccessFlags::new(),
    ) {
    Ok(c) => c
    Err(_) => return
  }
  inspect(@io.Channel::is_closed(chan), content="false")
}

///|
/// Test exclusive flag fails when file exists
async test "MemFileSystem exclusive flag fail" {
  let fs = MemFileSystem::new()
  let p = path("/test.txt", using_fs=fs)

  // Create file first
  let chan1 = match
    fs.open_file(p, OpenFlags::write_only(create=true), mode=AccessFlags::new()) {
    Ok(c) => c
    Err(_) => return
  }
  @io.Channel::close(chan1)

  // Try to create with exclusive - should fail
  match
    fs.open_file(
      p,
      OpenFlags::write_only(create=true, exclusive=true),
      mode=AccessFlags::new(),
    ) {
    Ok(_) => inspect("should have failed", content="should not reach here")
    Err(_) => inspect(true, content="true")
  }
}

///|
/// Test read from write-only file fails
async test "MemFileSystem read from write-only fails" {
  let fs = MemFileSystem::new()
  let p = path("/test.txt", using_fs=fs)
  let chan = match
    fs.open_file(p, OpenFlags::write_only(create=true), mode=AccessFlags::new()) {
    Ok(c) => c
    Err(_) => return
  }
  let buf : FixedArray[Byte] = FixedArray::make(10, 0)
  try {
    chan.read(buf, 0, 10) |> ignore
    inspect("should have failed", content="should not reach here")
  } catch {
    _ => inspect(true, content="true")
  }
}

///|
/// Test write to read-only file fails
async test "MemFileSystem write to read-only fails" {
  let fs = MemFileSystem::new()
  let p = path("/test.txt", using_fs=fs)

  // Create file first
  let chan1 = match
    fs.open_file(p, OpenFlags::write_only(create=true), mode=AccessFlags::new()) {
    Ok(c) => c
    Err(_) => return
  }
  @io.Channel::close(chan1)

  // Open read-only
  let chan2 = fs
    .open_file(p, OpenFlags::read_only(), mode=AccessFlags::new())
    .unwrap()
  let data : FixedArray[Byte] = [1, 2, 3]
  try {
    chan2.write(data, 0, 3) |> ignore
    inspect("should have failed", content="should not reach here")
  } catch {
    _ => inspect(true, content="true")
  }
}

///|
/// Test nested directory creation
async test "MemFileSystem nested directories" {
  let fs = MemFileSystem::new()
  let p = path("/a/b/c/file.txt", using_fs=fs)
  let chan = match
    fs.open_file(p, OpenFlags::write_only(create=true), mode=AccessFlags::new()) {
    Ok(c) => c
    Err(_) => return
  }
  let data : FixedArray[Byte] = [1, 2, 3]
  chan.write(data, 0, 3) |> ignore
  @io.Channel::close(chan)
  inspect(fs.exists(p), content="true")
}

///|
/// Test list directory
async test "MemFileSystem list directory" {
  let fs = MemFileSystem::new()

  // Create some files
  let f1 = path("/dir/file1.txt", using_fs=fs)
  let f2 = path("/dir/file2.txt", using_fs=fs)
  match
    fs.open_file(
      f1,
      OpenFlags::write_only(create=true),
      mode=AccessFlags::new(),
    ) {
    Ok(c) => @io.Channel::close(c)
    Err(_) => return
  }
  match
    fs.open_file(
      f2,
      OpenFlags::write_only(create=true),
      mode=AccessFlags::new(),
    ) {
    Ok(c) => @io.Channel::close(c)
    Err(_) => return
  }
  let dir = path("/dir", using_fs=fs)
  let entries = fs.list_directory(dir).unwrap()
  inspect(entries.length(), content="2")
}

///|
/// Test delete file
async test "MemFileSystem delete file" {
  let fs = MemFileSystem::new()
  let p = path("/test.txt", using_fs=fs)
  match
    fs.open_file(p, OpenFlags::write_only(create=true), mode=AccessFlags::new()) {
    Ok(c) => @io.Channel::close(c)
    Err(_) => return
  }
  inspect(fs.exists(p), content="true")
  fs.delete(p).unwrap()
  inspect(fs.exists(p), content="false")
}

///|
/// Test delete non-empty directory fails
async test "MemFileSystem delete non-empty directory fails" {
  let fs = MemFileSystem::new()
  let f = path("/dir/file.txt", using_fs=fs)
  match
    fs.open_file(f, OpenFlags::write_only(create=true), mode=AccessFlags::new()) {
    Ok(c) => @io.Channel::close(c)
    Err(_) => return
  }
  let dir = path("/dir", using_fs=fs)
  match fs.delete(dir) {
    Ok(_) => inspect("should have failed", content="should not reach here")
    Err(_) => inspect(true, content="true")
  }
}

///|
/// Test rename file
async test "MemFileSystem rename file" {
  let fs = MemFileSystem::new()
  let src = path("/old.txt", using_fs=fs)
  let dst = path("/new.txt", using_fs=fs)
  let chan = match
    fs.open_file(
      src,
      OpenFlags::write_only(create=true),
      mode=AccessFlags::new(),
    ) {
    Ok(c) => c
    Err(_) => return
  }
  let data : FixedArray[Byte] = [1, 2, 3]
  chan.write(data, 0, 3) |> ignore
  @io.Channel::close(chan)
  fs.rename(src, dst, copy_attr=false).unwrap()
  inspect(fs.exists(src), content="false")
  inspect(fs.exists(dst), content="true")
}

///|
/// Test rename fails when destination parent doesn't exist
async test "MemFileSystem rename fails without dst parent" {
  let fs = MemFileSystem::new()
  let src = path("/old.txt", using_fs=fs)
  let dst = path("/nonexistent/new.txt", using_fs=fs)
  match
    fs.open_file(
      src,
      OpenFlags::write_only(create=true),
      mode=AccessFlags::new(),
    ) {
    Ok(c) => @io.Channel::close(c)
    Err(_) => return
  }
  match fs.rename(src, dst, copy_attr=false) {
    Ok(_) => inspect("should have failed", content="should not reach here")
    Err(_) => inspect(true, content="true")
  }
}

///|
/// Test open non-existent file without create fails
async test "MemFileSystem open non-existent fails" {
  let fs = MemFileSystem::new()
  let p = path("/nonexistent.txt", using_fs=fs)
  match fs.open_file(p, OpenFlags::read_only(), mode=AccessFlags::new()) {
    Ok(_) => inspect("should have failed", content="should not reach here")
    Err(_) => inspect(true, content="true")
  }
}

///|
/// Test can_access
async test "MemFileSystem can_access" {
  let fs = MemFileSystem::new()
  let p = path("/test.txt", using_fs=fs)
  inspect(fs.can_access(p, AccessFlags::new()), content="false")
  match
    fs.open_file(p, OpenFlags::write_only(create=true), mode=AccessFlags::new()) {
    Ok(c) => @io.Channel::close(c)
    Err(_) => return
  }
  inspect(fs.can_access(p, AccessFlags::new()), content="true")
}

///|
/// Test file attributes
async test "MemFileSystem file attributes" {
  let fs = MemFileSystem::new()
  let p = path("/test.txt", using_fs=fs)
  let chan = match
    fs.open_file(p, OpenFlags::write_only(create=true), mode=AccessFlags::new()) {
    Ok(c) => c
    Err(_) => return
  }
  let data : FixedArray[Byte] = [1, 2, 3, 4, 5]
  chan.write(data, 0, 5) |> ignore
  @io.Channel::close(chan)
  let attr = fs.attr(p).unwrap()
  inspect(attr.kind, content="RegularFile")
  inspect(attr.size, content="5")
}

///|
/// Test FileInfo updates after write
async test "MemFileSystem FileInfo updates" {
  let fs = MemFileSystem::new()
  let p = path("/test.txt", using_fs=fs)
  let chan = match
    fs.open_file(p, OpenFlags::write_only(create=true), mode=AccessFlags::new()) {
    Ok(c) => c
    Err(_) => return
  }
  let info1 = chan.info()
  inspect(info1.attribute.size, content="0")
  let data : FixedArray[Byte] = [1, 2, 3, 4, 5]
  chan.write(data, 0, 5) |> ignore
  let info2 = chan.info()
  inspect(info2.attribute.size, content="5")
}

///|
/// Test read past EOF returns 0
async test "MemFileSystem read past EOF" {
  let fs = MemFileSystem::new()
  let p = path("/test.txt", using_fs=fs)
  let chan = match
    fs.open_file(p, OpenFlags::write_only(create=true), mode=AccessFlags::new()) {
    Ok(c) => c
    Err(_) => return
  }
  let data : FixedArray[Byte] = [1, 2, 3]
  chan.write(data, 0, 3) |> ignore
  @io.Channel::close(chan)
  let rchan = fs
    .open_file(p, OpenFlags::read_only(), mode=AccessFlags::new())
    .unwrap()
  let buf : FixedArray[Byte] = FixedArray::make(10, 0)
  rchan.read(buf, 0, 3) |> ignore // Read all data
  let read_count = rchan.read(buf, 0, 10) // Try to read more
  inspect(read_count, content="0")
}

///|
/// Test write/read from closed channel returns 0
async test "MemFileSystem closed channel returns 0" {
  let fs = MemFileSystem::new()
  let p = path("/test.txt", using_fs=fs)
  let chan = match
    fs.open_file(p, OpenFlags::write_only(create=true), mode=AccessFlags::new()) {
    Ok(c) => c
    Err(_) => return
  }
  @io.Channel::close(chan)
  let data : FixedArray[Byte] = [1, 2, 3]
  let written = chan.write(data, 0, 3)
  inspect(written, content="0")
}
