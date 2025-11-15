///|
async test "MemFileSystem basic file operations" {
  let fs = MemFileSystem::new()
  set_default_fs(fs)

  // Create and write to a file
  let p = path("/test.txt", using_fs=fs)
  let chan = fs.open_file(
    p,
    OpenFlags::write_only(create=true),
    mode=AccessFlags::new(),
  )
  let data : FixedArray[Byte] = [72, 101, 108, 108, 111] // "Hello"
  let written = chan.write(data, 0, 5)
  inspect(written, content="5")

  // Read back
  let rchan = fs.open_file(p, OpenFlags::read_only(), mode=AccessFlags::new())
  let buf : FixedArray[Byte] = FixedArray::make(10, 0)
  let read = rchan.read(buf, 0, 10)
  inspect(read, content="5")
  inspect(buf[0], content="b'\\x48'")
  inspect(buf[1], content="b'\\x65'")

  // Check exists
  let exists = fs.exists(p)
  inspect(exists, content="true")

  // Get attributes
  let attr = fs.attr(p)
  inspect(attr.kind, content="RegularFile")
  inspect(attr.size, content="5")
}

///|
async test "MemFileSystem directory operations" {
  let fs = MemFileSystem::new()
  set_default_fs(fs)

  // Create a nested file
  let p = path("/dir1/dir2/file.txt", using_fs=fs)
  let _chan = fs.open_file(
    p,
    OpenFlags::write_only(create=true),
    mode=AccessFlags::new(),
  )

  // List directory
  let dir = path("/dir1/dir2", using_fs=fs)
  let entries = fs.list_directory(dir)
  inspect(entries.length(), content="1")

  // Delete file
  fs.delete(p)
  let exists = fs.exists(p)
  inspect(exists, content="false")
}

///|
async test "MemFileSystem rename" {
  let fs = MemFileSystem::new()
  set_default_fs(fs)
  let src = path("/old.txt", using_fs=fs)
  let dst = path("/new.txt", using_fs=fs)

  // Create source file
  let chan = fs.open_file(
    src,
    OpenFlags::write_only(create=true),
    mode=AccessFlags::new(),
  )
  let data : FixedArray[Byte] = [65, 66, 67] // "ABC"
  chan.write(data, 0, 3) |> ignore

  // Rename
  fs.rename(src, dst, copy_attr=false)

  // Check old doesn't exist, new does
  inspect(fs.exists(src), content="false")
  inspect(fs.exists(dst), content="true")

  // Read renamed file
  let rchan = fs.open_file(dst, OpenFlags::read_only(), mode=AccessFlags::new())
  let buf : FixedArray[Byte] = FixedArray::make(5, 0)
  let read = rchan.read(buf, 0, 5)
  inspect(read, content="3")
  inspect(buf[0], content="b'\\x41'")
}
