///|
struct LibuvFileSystem {
  rt : LibuvRuntime
}

///|
fn uv(self : LibuvFileSystem) -> @uv.Loop {
  self.rt.uv
}

///|
fn to_uv_flags(self : @fs.OpenFlags) -> @uv.OpenFlags {
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
impl @fs.FileSystem for LibuvFileSystem with open_file(
  self,
  path,
  mode,
  permission~,
) {
  let path_bytes = @encoding/utf8.encode(path.to_unix_path())
  uvrt_suspend((ok, _fail, task) => try
    self
    .uv()
    .fs_open(path_bytes, mode.to_uv_flags(), permission, file => ok(file), err => _fail(
      err,
    ))
  catch {
    e => {
      _fail(e)
      () => ()
    }
  } noraise {
    handle =>
      () => {
        handle.cancel()
        _fail(@rt.CoroutineError::Cancelled)
      }
  })
}
