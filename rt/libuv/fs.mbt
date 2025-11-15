///|
struct LibuvFileSystem {
  rt : LibuvRuntime
}

///|
fn LibuvFileSystem::uv(self : LibuvFileSystem) -> @uv.Loop {
  self.rt.uv
}

///|
fn uv_error_to_file_error(err : Error, default_msg : String) -> @fs.FileError {
  let err_str = err.to_string()
  // Try to match common libuv error codes
  if err_str.contains("ENOENT") {
    @fs.FileError::NotFound(msg=err_str)
  } else if err_str.contains("EACCES") || err_str.contains("EPERM") {
    @fs.FileError::PermissionDenied(msg=err_str)
  } else if err_str.contains("EEXIST") {
    @fs.FileError::AlreadyExists(msg=err_str)
  } else if err_str.contains("ENOTDIR") {
    @fs.FileError::NotADirectory(msg=err_str)
  } else if err_str.contains("EISDIR") {
    @fs.FileError::IsADirectory(msg=err_str)
  } else {
    @fs.FileError::IoError(msg="\{default_msg}: \{err_str}")
  }
}

///|
impl @fs.FileSystem for LibuvFileSystem with open_file(
  self,
  path,
  flag,
  mode~,
  follow_links?,
) {
  let follow_links = follow_links.unwrap_or(true)
  let resolved_path = if follow_links {
    match self.real_path(path) {
      Ok(p) => p
      Err(e) => return Err(e)
    }
  } else {
    path
  }
  LibuvFile::new(rt=self.rt, path=resolved_path, flag~, mode~)
}

///|
impl @fs.FileSystem for LibuvFileSystem with id(self) {
  "libuv"
}

///|
fn @fs.Path::to_bytes(self : @fs.Path) -> Bytes {
  @encoding/utf8.encode(self.to_unix_path())
}

///|
impl @fs.FileSystem for LibuvFileSystem with attr(self, path, follow_links?) {
  let uv = self.uv()
  let follow_links = follow_links.unwrap_or(true)
  let path_bytes = path.to_bytes()
  match (try? uvrt_op_suspend((resolve, reject, _) => {
      let on_stat : (@uv.Stat) -> Unit = stat => resolve(@fs.FileAttribute::{
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
        permission: stat.mode(),
        size: stat.size(),
        kind: to_file_kind(stat),
      })
      let handle = if follow_links {
        uv.fs_stat(path_bytes, on_stat, err => reject(err))
      } else {
        uv.fs_lstat(path_bytes, on_stat, err => reject(err))
      }
      () => {
        defer reject(@rt.CoroutineError::Cancelled)
        handle.cancel()
      }
    })) {
    Ok(attr) => Ok(attr)
    Err(@rt.CoroutineError::Cancelled) => raise @rt.CoroutineError::Cancelled
    Err(@rt.CoroutineError::ExecutionError(err)) =>
      Err(uv_error_to_file_error(err, "Failed to get file attributes"))
  }
}

///|
impl @fs.FileSystem for LibuvFileSystem with list_directory(self, path) {
  let path_bytes = path.to_bytes()
  let uv = self.uv()
  //todo need a async iterator that utilizes structured concurrency..
  match (try? uvrt_op_suspend((resolve, reject, _) => {
      let mut cancelled = false
      let handle = uv.fs_scandir(
        path_bytes,
        0,
        scdir => {
          let collected : Array[@fs.Path] = []
          while true {
            if cancelled {
              return
            }
            let value = scdir.next() catch { _ => break }
            guard (try? @encoding/utf8.decode(value.name())) is Ok(name)
            collected.push(path.resolve(name))
          }
          resolve(collected)
        },
        err => reject(err),
      )
      () => {
        defer reject(@rt.CoroutineError::Cancelled)
        cancelled = true
        handle.cancel()
      }
    })) {
    Ok(paths) => Ok(paths)
    Err(@rt.CoroutineError::Cancelled) => raise @rt.CoroutineError::Cancelled
    Err(@rt.CoroutineError::ExecutionError(err)) =>
      Err(uv_error_to_file_error(err, "Failed to list directory"))
  }
}

///|
fn to_uv_access(mode : @fs.AccessFlags) -> @uv.AccessFlags {
  @uv.AccessFlags::new(
    read=mode.read(),
    write=mode.write(),
    execute=mode.execute(),
  )
}

///|
fn access_flag_inner(flag : @uv.AccessFlags) -> Int = "%identity"

///|
impl @fs.FileSystem for LibuvFileSystem with can_access(self, path, mode) {
  let path_bytes = path.to_bytes()
  let uv = self.uv()
  uvrt_op_suspend((resolve, reject, _) => {
    let handle = uv.fs_access(
      path_bytes,
      to_uv_access(mode),
      () => resolve(true),
      _ => resolve(false),
    )
    () => {
      defer reject(@rt.CoroutineError::Cancelled)
      handle.cancel()
    }
  })
}

///|
impl @fs.FileSystem for LibuvFileSystem with delete(self, path) {
  let uv = self.uv()
  match (try? uvrt_op_suspend((a, b, _) => {
      let handle = uv.fs_unlink(
        @encoding/utf8.encode(path.to_unix_path()),
        () => a(()),
        err => b(err),
      )
      () => {
        defer b(@rt.CoroutineError::Cancelled)
        handle.cancel()
      }
    })) {
    Ok(()) => Ok(())
    Err(@rt.CoroutineError::Cancelled) => raise @rt.CoroutineError::Cancelled
    Err(@rt.CoroutineError::ExecutionError(err)) =>
      Err(uv_error_to_file_error(err, "Failed to delete file"))
  }
}

///|
impl @fs.FileSystem for LibuvFileSystem with exists(self, path) {
  self.can_access(path, @fs.AccessFlags::new())
}

///|
impl @fs.FileSystem for LibuvFileSystem with read_symbol_link(self, path) {
  let uv = self.uv()
  match (try? uvrt_op_suspend((resolve, reject, _) => {
      let handle = uv.fs_readlink(
        @encoding/utf8.encode(path.to_unix_path()),
        bytes => @fs.path(
            (try? @encoding/utf8.decode(bytes)).unwrap(), // assertion
            using_fs=self,
          )
          |> resolve,
        err => reject(err),
      )
      () => {
        defer reject(@rt.CoroutineError::Cancelled)
        handle.cancel()
      }
    })) {
    Ok(p) => Ok(p)
    Err(@rt.CoroutineError::Cancelled) => raise @rt.CoroutineError::Cancelled
    Err(@rt.CoroutineError::ExecutionError(err)) =>
      Err(uv_error_to_file_error(err, "Failed to read symbolic link"))
  }
}

///|
impl @fs.FileSystem for LibuvFileSystem with rename(self, src, dst, copy_attr~) {
  ignore(copy_attr)
  let uv = self.uv()
  // todo: support copy_attr
  match (try? uvrt_op_suspend((resolve, reject, _) => {
      let handle = uv.fs_rename(
        @encoding/utf8.encode(src.to_unix_path()),
        @encoding/utf8.encode(dst.to_unix_path()),
        () => resolve(()),
        err => reject(err),
      )
      () => {
        defer reject(@rt.CoroutineError::Cancelled)
        handle.cancel()
      }
    })) {
    Ok(()) => Ok(())
    Err(@rt.CoroutineError::Cancelled) => raise @rt.CoroutineError::Cancelled
    Err(@rt.CoroutineError::ExecutionError(err)) =>
      Err(uv_error_to_file_error(err, "Failed to rename file"))
  }
}

///|
impl @fs.FileSystem for LibuvFileSystem with cwd(self) {
  try {
    let cwd = @uv.cwd()
    @fs.path(@encoding/utf8.decode(cwd), using_fs=self)
  } catch {
    _ => panic()
  }
}

///|
impl @fs.FileSystem for LibuvFileSystem with system_roots(self) {
  // todo: windows support
  [@fs.path("", using_fs=self)]
}

///|
impl @fs.FileSystem for LibuvFileSystem with real_path(self, path) {
  let uv = self.uv()
  match (try? uvrt_op_suspend((resolve, reject, _) => {
      let handle = uv.fs_realpath(
        @encoding/utf8.encode(path.to_unix_path()),
        bytes => resolve(
          @fs.path((try? @encoding/utf8.decode(bytes)).unwrap(), using_fs=self),
        ),
        err => reject(err),
      )
      () => {
        defer reject(@rt.CoroutineError::Cancelled)
        handle.cancel()
      }
    })) {
    Ok(p) => Ok(p)
    Err(@rt.CoroutineError::Cancelled) => raise @rt.CoroutineError::Cancelled
    Err(@rt.CoroutineError::ExecutionError(err)) =>
      Err(uv_error_to_file_error(err, "Failed to resolve real path"))
  }
}
