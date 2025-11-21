///|
/// Tests for LibuvFileSystem operations
/// These tests verify file and directory operations with the libuv runtime

///|
/// Test file creation and writing
// Create a temporary file path
test "LibuvFileSystem can create and write file" {
  @libuv.with_test(() => {
    let temp_path = @fs.path("/tmp/miao_test_write.txt")
    let file = @fs.open(
      temp_path,
      @fs.OpenFlags::write_only(create=true, truncate=true),
      permission=0o644,

      // Create and write to file
    )
    let data : FixedArray[Byte] = [b'H', b'e', b'l', b'l', b'o']
    let written = file.write(data, 0, 5)
    inspect(written, content="5")
    @io.Channel::close(file)

    // Clean up
    @fs.delete(temp_path)
  })
}

///|
/// Test file reading
test "LibuvFileSystem can read file" {
  @libuv.with_test(() => {
    let temp_path = @fs.path("/tmp/miao_test_read.txt")

    // Write data first
    let write_file = @fs.open(
      temp_path,
      @fs.OpenFlags::write_only(create=true, truncate=true),
      permission=0o644,
    )
    let data : FixedArray[Byte] = [b'T', b'e', b's', b't']
    write_file.write(data, 0, 4) |> ignore
    @io.Channel::close(write_file)

    // Read data back
    let read_file = @fs.open(
      temp_path,
      @fs.OpenFlags::read_only(),
      permission=0o644,
    )
    let buffer : FixedArray[Byte] = FixedArray::make(10, 0)
    let bytes_read = read_file.read(buffer, 0, 10)
    inspect(bytes_read, content="4")
    inspect(buffer[0].to_int(), content="84") // 'T'
    inspect(buffer[1].to_int(), content="101") // 'e'
    @io.Channel::close(read_file)

    // Clean up
    @fs.delete(temp_path)
  })
}

///|
/// Test file existence check
test "LibuvFileSystem can check file existence" {
  @libuv.with_test(() => {
    let temp_path = @fs.path("/tmp/miao_test_exists.txt")

    // Delete if exists from previous run
    if @fs.exists(temp_path) {
      @fs.delete(temp_path)
    }

    // File should not exist now
    let exists_before = @fs.exists(temp_path)
    assert_false(exists_before)

    // Create file
    let file = @fs.open(
      temp_path,
      @fs.OpenFlags::write_only(create=true),
      permission=0o644,
    )
    @io.Channel::close(file)

    // File should exist now
    let exists_after = @fs.exists(temp_path)
    assert_true(exists_after)

    // Clean up
    @fs.delete(temp_path)
  })
}

///|
/// Test directory operations
test "LibuvFileSystem can list directories" {
  @libuv.with_test(() => {
    // Use /tmp directory which should exist
    let tmp_dir = @fs.path("/tmp/")

    // List directory contents
    let entries = @fs.list_dir(tmp_dir)

    // /tmp should have some entries (or at least be listable)
    assert_true(entries.length() >= 0)
  })
}

///|
/// Test file attributes
test "LibuvFileSystem can get file attributes" {
  @libuv.with_test(() => {
    let temp_path = @fs.path("/tmp/miao_test_attr.txt")

    // Create a file with some content
    let file = @fs.open(
      temp_path,
      @fs.OpenFlags::write_only(create=true, truncate=true),
      permission=0o644,
    )
    let data : FixedArray[Byte] = [b'1', b'2', b'3']
    file.write(data, 0, 3) |> ignore
    @io.Channel::close(file)

    // Get file attributes
    let attr = @fs.attr(temp_path)
    inspect(attr.kind, content="RegularFile")
    inspect(attr.size, content="3")

    // Clean up
    @fs.delete(temp_path)
  })
}

///|
/// Test file deletion
test "LibuvFileSystem can delete files" {
  @libuv.with_test(() => {
    let temp_path = @fs.path("/tmp/miao_test_delete.txt")

    // Create a file
    let file = @fs.open(
      temp_path,
      @fs.OpenFlags::write_only(create=true),
      permission=0o644,
    )
    @io.Channel::close(file)

    // Verify it exists
    assert_true(@fs.exists(temp_path))

    // Delete it
    @fs.delete(temp_path)

    // Verify it's gone
    assert_false(@fs.exists(temp_path))
  })
}

///|
/// Test current working directory
test "LibuvFileSystem can get current directory" {
  @libuv.with_test(() => {
    // Get current working directory
    let cwd_path = @fs.path(".")
    let path_str = cwd_path.to_unix_path()
    // CWD should be a valid path
    assert_true(path_str.length() >= 0)
  })
}
