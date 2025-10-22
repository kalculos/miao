
///|
pub async fn open(
  path : Path,
  mode : AccessMode,
  permission~ : Int,
) -> &FileChannel {
  path.fs.open_file(path, mode, permission~)
}

///|
pub async fn size(path : Path) -> Int64 {
  path.fs.size(path)
}

///|
pub async fn attr(path : Path) -> FileAttribute {
  path.fs.attr(path)
}

///|
pub async fn list_dir(path : Path) -> ArrayView[Path] {
  path.fs.list_directory(path)
}

///|
pub async fn exists(path : Path) -> Bool {
  path.fs.exists(path)
}

///|
pub async fn delete(path : Path) -> Unit {
  path.fs.delete(path)
}

///|
pub async fn delete_if_exist(path : Path) -> Unit {
  if exists(path) {
    delete(path)
  }
}

///|
pub async fn read_symbolic_link(path : Path) -> Path? {
  (try? path.fs.read_symbol_link(path)).to_option()
}
