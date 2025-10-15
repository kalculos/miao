///|
/// A FileSystem handles I/O operations to files that is associated with a unique
///  string (path) given from the filesystem. A FileSystem does not strictly related to a specific disk partition or 
/// any filesystem softwares. For example, the whole accessible local storage is considered as a FileSystem.
pub(open) trait FileSystem {
  async is_read_only(Self) -> Unit
  async open_file(Self, Path, mode : Int) -> &@miao.Channel
}

///|
/// A Path is an immutable object that associates a filepath string and its corresponding filesystem, to unify access between real filesystems and virtual file systems.
/// It also provides several useful utilities to for path string manipulation.
/// 
pub(all) struct Path {
  fs : &FileSystem
  priv components : ArrayView[String]
}

///|
pub fn path(str : String) -> Path {
  //todo windows support?
  str.split("/").to_array()
}

pub fn to_unix_path(self: Path) -> String {
  self.components.join("/")
}
