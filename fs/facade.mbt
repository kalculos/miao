///|
pub async fn open(
  path : Path,
  mode : OpenFlags,
  permission~ : Int,
) -> Result[&FileChannel, FileError] {
  path.fs.open_file(path, mode, mode=permission)
}

///|
pub async fn size(path : Path) -> Result[UInt64, FileError] {
  path.fs.attr(path).map(fn(attr) { attr.size })
}

///|
pub async fn attr(path : Path) -> Result[FileAttribute, FileError] {
  path.fs.attr(path)
}

///|
pub async fn list_dir(path : Path) -> Result[ArrayView[Path], FileError] {
  path.fs.list_directory(path)
}

///|
pub async fn exists(path : Path) -> Bool {
  path.fs.exists(path)
}

///|
pub async fn delete(path : Path) -> Result[Unit, FileError] {
  path.fs.delete(path)
}

///|
pub async fn delete_if_exist(path : Path) -> Result[Unit, FileError] {
  if exists(path) {
    delete(path)
  } else {
    Ok(())
  }
}

///|
pub async fn read_symbolic_link(path : Path) -> Result[Path, FileError] {
  path.fs.read_symbol_link(path)
}
