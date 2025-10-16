///|
struct LocalFileSystem {}

///|
fn to_asyncfs_mode(self : AccessMode) -> @asyncfs.Mode {
  match self {
    WriteOnly => @asyncfs.Mode::WriteOnly
    ReadOnly => @asyncfs.Mode::ReadOnly
    ReadWrite => @asyncfs.Mode::ReadWrite
  }
}

//todo mode should be a bitset

///|
pub impl FileSystem for LocalFileSystem with open_file(
  self,
  path,
  mode,
  permission~,
) {
  let abs_path = self.to_absolute(path)
  let unix_path = abs_path.to_unix_path()
  let file = @asyncfs.open(
    unix_path,
    mode=mode.to_asyncfs_mode(),
    create=permission,
  ) catch {
    err =>
      raise FileError::Inaccessible(path~, error=err, msg="Cannot open file") // TODO: detailed message
  }
  LocalFileChannel::{ fs: self, mode, closed: false, file }
}

///|
pub impl FileSystem for LocalFileSystem with size(self, path) { // stat is currently internal so we must open..
  let abs_path = self.to_absolute(path).to_unix_path()
  let file = @asyncfs.open(abs_path, mode=@asyncfs.Mode::ReadOnly) catch {
    err =>
      raise FileError::Inaccessible(path~, error=err, msg="Cannot open file")
  }
  defer file.close()
  file.size() catch {
    err =>
      raise FileError::Inaccessible(
        path~,
        error=err,
        msg="Cannot get size of file",
      )
  }
}

///|
pub impl FileSystem for LocalFileSystem with attr(self, path) {
  let abs_path = self.to_absolute(path).to_unix_path()
  let file = @asyncfs.open(abs_path, mode=@asyncfs.ReadOnly) catch {
    err =>
      raise FileError::Inaccessible(path~, error=err, msg="Cannot open file")
  }
  defer file.close()
  FileAttribute::{
    last_access_time: file.atime().0,
    last_modified_time: file.mtime().0,
    creation_time: file.ctime().0,
    permission: 0, // todo
    size: file.size(),
    kind: match file.kind() {
      BlockDevice => Unknown
      Pipe => Unknown
      Socket => Unknown
      SymLink => Link
      Directory => Directory
      Regular => RegularFile
      Unknown => Unknown
      CharDevice => Unknown
    },
  } catch {
    err =>
      raise FileError::Inaccessible(path~, error=err, msg="Cannot stat file")
  }
}

///|
pub impl FileSystem for LocalFileSystem with list_directory(self, path) { // todo visit options(for hidden and special files)
  let abs_path = self.to_absolute(path).to_unix_path()
  let dir = @asyncfs.opendir(abs_path) catch {
    err =>
      raise FileError::Inaccessible(
        path~,
        error=err,
        msg="Cannot open directory",
      )
  }
  defer dir.close()
  try {
    let entries = dir.read_all(include_hidden=true, include_special=true)
    entries.map(it => path.resolve(it))
  } catch {
    err => raise Inaccessible(path~, error=err, msg="Cannot read directory")
  }
}

///|
pub impl FileSystem for LocalFileSystem with can_access(self, path, mode~) {
  let abs_path = self.to_absolute(path).to_string()
  match mode { // todo: can_execute?
    WriteOnly => @asyncfs.can_write(abs_path)
    ReadOnly => @asyncfs.can_read(abs_path)
    ReadWrite => @asyncfs.can_write(abs_path) && @asyncfs.can_read(abs_path)
  }
}

///|
pub impl FileSystem for LocalFileSystem with delete(self, path) {
  let abs_path = self.to_absolute(path).to_unix_path()
  @asyncfs.remove(abs_path) catch {
    error =>
      raise FileError::Inaccessible(path~, error~, msg="Cannot remove file")
  }
}

///|
pub impl FileSystem for LocalFileSystem with exists(self, path) {
  @asyncfs.exists(path.to_absolute().to_unix_path())
}

///|
pub impl FileSystem for LocalFileSystem with read_symbol_link(self, _path) {
  let abs_path = self.to_absolute(_path).to_unix_path()
  let rpath = @asyncfs.realpath(abs_path) catch {
    error =>
      raise FileError::Inaccessible(
        path=_path,
        error~,
        msg="cannot resolve realpath of symbollic link",
      )
  }
  path(rpath)
}

///|
pub impl FileSystem for LocalFileSystem with move(
  self,
  src : Path,
  dst : Path,
  copy_attr~,
) {
  let abs_src = self.to_absolute(src)
  let abs_dst = self.to_absolute(dst)
  // TODO: unsupported os rename
  guard false
}

///|
pub impl FileSystem for LocalFileSystem with system_roots(self) {
  // For Unix-like systems, there's only one root
  [path("/")]
}

///|
pub impl FileSystem for LocalFileSystem with to_absolute(self, path) {
  if path.is_absolute() {
    path
  } else {
    // Create empty components for current directory path
    let empty : Array[StringView] = []
    Path::{ ..path, components: [..empty, ..path.components], absolute: true }
  }
}
