///|
struct LibuvFile {
  fd : @uv.File
  mut closed : Bool
  access : @fs.OpenFlags
  info : @fs.FileInfo
  uv : @uv.Loop
}

///|
fn @fs.OpenFlags::to_uv_flags(self : @fs.OpenFlags) -> @uv.OpenFlags {
  if self.is_read_only() {
    return @uv.OpenFlags::read_only()
  } else if self.is_write_only() {
    return @uv.OpenFlags::write_only(
      append=self.is_append(),
      create=self.is_create(),
      truncate=self.is_truncate(),
      exclusive=self.is_exclusive(),
    )
  }
  @uv.OpenFlags::read_write(
    append=self.is_append(),
    create=self.is_create(),
    truncate=self.is_truncate(),
    exclusive=self.is_exclusive(),
  )
}

///|
fn to_file_kind(stat : @uv.Stat) -> @fs.FileKind {
  return if stat.is_regular() {
    @fs.FileKind::RegularFile
  } else if stat.is_directory() {
    @fs.FileKind::Directory
  } else if stat.is_symlink() {
    @fs.FileKind::Link
  } else {
    @fs.FileKind::Unknown // todo complete more types
  }
}

///|
async fn gather_fattr(rt : LibuvRuntime, fd : @uv.File) -> @fs.FileAttribute {
  uvrt_op_suspend((resolve, reject, _) => {
    let handle = rt.uv.fs_fstat(
      fd,
      stat => {
        let fattr : @fs.FileAttribute = {
          last_modified_time: @time.Instant::new(
            stat.mtim_sec(),
            (stat.mtim_nsec() % 1000000000).to_int(),
          ),
          last_access_time: @time.Instant::new(
            stat.atim_sec(),
            (stat.atim_nsec() % 1000000000).to_int(),
          ),
          creation_time: @time.Instant::new(
            stat.ctim_sec(),
            (stat.ctim_nsec() % 1000000000).to_int(),
          ),
          permission: stat.mode(), // todo; use uint64
          size: stat.size(), // todo; use uint64
          kind: to_file_kind(stat),
        }
        resolve(fattr)
      },
      err => reject(err),
    )
    () => {
      defer reject(@rt.CoroutineError::Cancelled)
      handle.cancel()
    }
  })
}

///|
///1
async fn LibuvFile::new(
  rt~ : LibuvRuntime,
  path~ : @fs.Path,
  flag~ : @fs.OpenFlags,
  mode~ : @fs.AccessFlags,
) -> Result[&@fs.FileChannel, @fs.FileError] {
  let uv = rt.uv
  let path_bytes = @encoding/utf8.encode(path.to_unix_path())
  let fd = uvrt_op_suspend((resolve, reject, _) => {
    let handle = uv.fs_open(
      path_bytes,
      flag.to_uv_flags(),
      to_uv_access(mode) |> access_flag_inner,
      file => resolve(file),
      err => reject(err),
    )
    () => handle.cancel()
  }) catch {
    zerr =>
      match zerr {
        Cancelled => raise @rt.CoroutineError::Cancelled
        ExecutionError(err) => {
          let err_str = err.to_string()
          return if err_str.contains("ENOENT") {
            Err(@fs.FileError::NotFound(msg=err_str))
          } else if err_str.contains("EACCES") || err_str.contains("EPERM") {
            Err(@fs.FileError::PermissionDenied(msg=err_str))
          } else if err_str.contains("EEXIST") {
            Err(@fs.FileError::AlreadyExists(msg=err_str))
          } else if err_str.contains("ENOTDIR") || err_str.contains("EISDIR") {
            Err(@fs.FileError::UnexpectedKind(msg=err_str))
          } else {
            Err(@fs.FileError::IoError(msg="Failed to open file: \{err_str}"))
          }
        }
      }
  }
  let attr = gather_fattr(rt, fd) catch {
    e =>
      match e {
        @rt.CoroutineError::Cancelled => raise @rt.CoroutineError::Cancelled
        @rt.CoroutineError::ExecutionError(err) => {
          let err_str = err.to_string()
          return Err(
            @fs.FileError::IoError(
              msg="Failed to get file attributes: \{err_str}",
            ),
          )
        }
        other =>
          return Err(
            @fs.FileError::IoError(msg="Unknown error getting file attributes \{other}"),
          )
      }
  }

  Ok(LibuvFile::{
    fd,
    closed: false,
    access: flag,
    info: @fs.FileInfo::{ attribute: attr, path },
    uv: rt.uv,
  })
}

///|
pub fn LibuvFile::fd(self : LibuvFile) -> Int {
  self.fd.to_int()
}

///|
impl @fs.FileChannel for LibuvFile with access(self) {
  self.access
}

///|
impl @fs.FileChannel for LibuvFile with info(self) {
  self.info
}

///|
async fn LibuvFile::close(self : LibuvFile) -> Unit {
  guard !self.closed else {
    raise fail("File \{self.info.path} (fd: \{self.fd()}) is already closed!")
  }
  uvrt_op_suspend((resolve, reject, _) => {
    let handle = self.uv.fs_close(self.fd, () => resolve(()), err => reject(err))
    () => {
      handle.cancel()
      self.closed = false
      reject(@rt.CoroutineError::Cancelled)
    }
  })
}

///|
impl @io.Channel for LibuvFile with close(self) {
  self.close()
}

///|
impl @io.Channel for LibuvFile with is_closed(self) {
  self.closed
}

///|
impl @io.Writer for LibuvFile with write(self, arr, off, len) {
  uvrt_op_suspend((resolve, reject, _) => {
    let handle = self.uv.fs_write(
      self.fd,
      [arr.unsafe_reinterpret_as_bytes()[off:off + len]],
      written => resolve(written),
      err => reject(err),
    )
    () => {
      defer reject(@rt.CoroutineError::Cancelled)
      handle.cancel()
    }
  })
}

///|
impl @io.Writer for LibuvFile with close(self) {
  self.close()
}

///|
impl @io.Writer for LibuvFile with is_closed(self) {
  self.closed
}

///|
impl @io.Reader for LibuvFile with read(self, dst, off, len) {
  uvrt_op_suspend((resolve, reject, _) => {
    let handle = self.uv.fs_read(
      self.fd,
      [dst.unsafe_reinterpret_as_bytes()[off:off + len]],
      read => resolve(read),
      err => reject(err),
    )
    () => {
      defer reject(@rt.CoroutineError::Cancelled)
      handle.cancel()
    }
  })
}

///|
impl @io.Reader for LibuvFile with close(self) {
  self.close()
}

///|
impl @io.Reader for LibuvFile with is_closed(self) {
  self.closed
}
