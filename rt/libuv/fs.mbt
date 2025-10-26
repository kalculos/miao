///|
struct LibuvFileSystem {
  rt : LibuvRuntime
}

///|
fn uv(self : LibuvFileSystem) -> @uv.Loop {
  self.rt.uv
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
  if follow_links {
    LibuvFile::new(rt=self.rt, path=self.real_path(path), flag~, mode~)
  } else {
    LibuvFile::new(rt=self.rt, path~, flag~, mode~)
  }
}

///|
fn to_bytes(self : @fs.Path) -> Bytes {
  @encoding/utf8.encode(self.to_unix_path())
}

///|
impl @fs.FileSystem for LibuvFileSystem with attr(self, path, follow_links?) {
  let uv = self.uv()
  let follow_links = follow_links.unwrap_or(true)
  let path_bytes = path.to_bytes()
  uvrt_op_suspend((resolve, reject, _) => {
    let on_stat : (@uv.Stat) -> Unit = stat => resolve(@fs.FileAttribute::{
      last_modified_time: stat.mtim_sec() * 1000 + stat.mtim_nsec() / 1000,
      last_access_time: stat.atim_sec() * 1000 + stat.atim_nsec() / 1000,
      creation_time: stat.ctim_sec() * 1000 + stat.ctim_nsec() / 1000,
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
  })
}

///|
impl @fs.FileSystem for LibuvFileSystem with list_directory(self, path) {
  let path_bytes = path.to_bytes()
  let uv = self.uv()
  //todo need a async iterator that utilizes structured concurrency..
  uvrt_op_suspend((resolve, reject, _) => {
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
  })
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
fn access_flag_inner(self : @uv.AccessFlags) -> Int = "%identity"

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
  uvrt_op_suspend((a, b, _) => {
    let handle = uv.fs_unlink(
      @encoding/utf8.encode(path.to_unix_path()),
      () => a(()),
      err => b(err),
    )
    () => {
        defer b(@rt.CoroutineError::Cancelled)
        handle.cancel()
      }
  })
}

///|
impl @fs.FileSystem for LibuvFileSystem with exists(self, path) {
  self.can_access(path, @fs.AccessFlags::new())
}

///|
impl @fs.FileSystem for LibuvFileSystem with read_symbol_link(self, path) {
  let uv = self.uv()
  uvrt_op_suspend((resolve, reject, _) => {
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
  })
}

///|
impl @fs.FileSystem for LibuvFileSystem with move(self, src, dst, copy_attr~) {
  let uv = self.uv()
  // todo: support copy_attr
  uvrt_op_suspend((resolve, reject, _) => {
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
  })
}

///|
impl @fs.FileSystem for LibuvFileSystem with cwd(self) {
  try {
    let cwd = @uv.cwd()
    @fs.path(@encoding/utf8.decode(cwd), using_fs=self)
  } catch {
    err => panic()
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
  uvrt_op_suspend((resolve, reject, _) => {
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
  })
}
