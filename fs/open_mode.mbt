///| These codes are copied from tonyfettes/uv.mbt, which is licensed under Apache 2.0.
/// Modifications: `Example` sections were removed, and flag bits are independent from specific systems.

///|
struct OpenFlags(Int)

///|
let _O_RDONLY = 1

///|
let _O_WRONLY = 2

let _O_RDWR = 3 // 011

///|
let _O_APPEND: Int = 1 << 2

///|
let _O_CREATE: Int = 1 << 3

///|
let _O_TRUNCATE: Int = 1 << 4

///|
let _O_EXCLUSIVE: Int = (1 << 5)

///|
/// Creates file open flags for read-only access.
///
/// Returns an `OpenFlags` instance configured for read-only file access. Files
/// opened with these flags can only be read from, not written to or modified.
pub fn OpenFlags::read_only() -> OpenFlags {
  _O_RDONLY
}

///|
/// Creates file open flags for write-only access with configurable behaviors.
///
/// Parameters:
///
/// * `append` : Whether to append to the file instead of overwriting. When
///   `true`, writes will be positioned at the end of the file. Defaults to
///   `false`.
/// * `create` : Whether to create the file if it doesn't exist. When `true`, a
///   new file will be created if the specified path doesn't exist. Defaults to
///   `false`.1
/// * `truncate` : Whether to truncate the file to zero length when opening.
///   When `true`, any existing content will be discarded. Defaults to `false`.
/// * `exclusive` : Whether to fail if the file already exists when creating.
///   When `true` and `create` is also `true`, the operation will fail if the
///   file already exists. Defaults to `false`.
///
/// Returns an `OpenFlags` instance configured for write-only access with the
/// specified behaviors.
pub fn OpenFlags::write_only(
  append? : Bool = false,
  create? : Bool = false,
  truncate? : Bool = false,
  exclusive? : Bool = false,
) -> OpenFlags {
  let mut flags = _O_WRONLY
  if append {
    flags = flags | _O_APPEND
  }
  if create {
    flags = flags | _O_CREATE
  }
  if truncate {
    flags = flags | _O_TRUNCATE
  }
  if exclusive {
    flags = flags | _O_EXCLUSIVE
  }
  flags
}

///|
/// Creates file open flags for read-write access with configurable behaviors.
///
/// Parameters:
///
/// * `append` : Whether to append to the file instead of overwriting. When
///   `true`, writes will be positioned at the end of the file. Defaults to
///   `false`.
/// * `create` : Whether to create the file if it doesn't exist. When `true`, a
///   new file will be created if the specified path doesn't exist. Defaults to
///   `false`.
/// * `truncate` : Whether to truncate the file to zero length when opening. When
///   `true`, any existing content will be discarded. Defaults to `false`.
/// * `exclusive` : Whether to fail if the file already exists when creating.
///   When `true` and `create` is also `true`, the operation will fail if the
///   file already exists. Defaults to `false`.
///
/// Returns an `OpenFlags` instance configured for read-write access with the
/// specified behaviors.
pub fn OpenFlags::read_write(
  append? : Bool = false,
  create? : Bool = false,
  truncate? : Bool = false,
  exclusive? : Bool = false,
) -> OpenFlags {
  let mut flags = _O_RDWR
  if append {
    flags = flags | _O_APPEND
  }
  if create {
    flags = flags | _O_CREATE
  }
  if truncate {
    flags = flags | _O_TRUNCATE
  }
  if exclusive {
    flags = flags | _O_EXCLUSIVE
  }
  flags
}

pub fn OpenFlags::is_append(self: OpenFlags) -> Bool {
  (self.0 & _O_APPEND) != 0
}

pub fn OpenFlags::is_create(self: OpenFlags) -> Bool {
  (self.0 & _O_CREATE) != 0
}

pub fn OpenFlags::is_truncate(self: OpenFlags) -> Bool {
  (self.0 & _O_TRUNCATE) != 0
}

pub fn OpenFlags::is_exclusive(self: OpenFlags) -> Bool {
  (self.0 & _O_EXCLUSIVE) != 0
}

pub fn OpenFlags::has_read(self: OpenFlags) -> Bool {
  (self.0 & _O_RDONLY) != 0
}

pub fn OpenFlags::has_write(self: OpenFlags) -> Bool {
  (self.0 & _O_WRONLY) != 0
}

pub fn OpenFlags::is_read_write(self: OpenFlags) -> Bool {
  (self.0 & _O_RDWR) != 0
}

pub fn OpenFlags::is_read_only(self: OpenFlags) -> Bool {
  (self.0 & 0b11) == _O_RDONLY
}

pub fn OpenFlags::is_write_only(self: OpenFlags) -> Bool {
  (self.0 & 0b11) == _O_WRONLY
}