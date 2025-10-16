///|
pub enum FileKind {
  RegularFile
  Directory
  Link
}

///|
pub(all) struct FileAttribute {
  last_modified_time : Int64
  last_access_time : Int64
  permission : Int
  size : Int64
  kind : FileKind
}

pub suberror FileError {
  IncorrectKind(path~: Path, expect~: FileKind, actual~: FileKind)
  NotExist(path~: Path)
  Inaccessible(path~: Path, error~: Error)
}

///|
/// A FileSystem handles I/O operations to files that is associated with a unique
///  string (path) given from the filesystem. A FileSystem does not strictly related to a specific disk partition or 
/// any filesystem softwares. For example, the whole accessible local storage is considered as a FileSystem.
pub(open) trait FileSystem {
  ///| Open a file and return its corresponding FileChannnel
  async open_file(Self, Path, mode : Int, permission~ : Int) -> &FileChannel
  ///| Check the size of file, if exists. 
  /// Raises an error if the file is not exist.
  async size(Self, Path) -> Int64 raise FileError
  ///| Get attributes of the file. Raise if the file not exists
  async attr(Self, Path) -> FileAttribute raise FileError
  ///| List the content of the file. Raise if the file is not a directory
  async list_directory(Self, Path) -> ArrayView[Path] raise FileError
  ///| Check if we can access the file. Return false if the file is inaccessible or not exist
  async can_access(Self, Path, mode~ : Int) -> Bool
  ///| Delete a file.
  async delete(Self, Path) -> Unit raise FileError
  async exists(Self, Path) -> Bool
  ///| Resolves a symbol link. Raise if the path is not a symbol link
  async read_symbol_link(Self, Path) -> Path raise FileError
  ///| Move a file to another path. Raise if the operation is failed.
  async move(Self, src: Path, dst: Path, copy_attr~ : Bool) -> Unit raise FileError
  ///| List file roots. An absolute path usually starts with these paths
  system_roots(Self) -> ArrayView[Path]
}

///|
/// A Path is an immutable object that associates a filepath string and its corresponding filesystem, to unify access between real filesystems and virtual file systems.
/// Path consists of components. Like "a/b" where the components are ["a", "b"]. for root folder, it has no component.("/"). Path can also used to describe relative relationships.
/// Implementations of this interface are immutable and safe for use by multiple concurrent threads.
/// 
/// Absolute Path: An absolute path is complete in that it doesn't need to be combined with other path information in order to locate a file.
/// Whether a path is absolute or not is determined on construction.
/// 
pub(all) struct Path {
  fs : &FileSystem
  priv absolute : Bool
  priv components : ArrayView[StringView]
}

///| A factory of path. It parses the input in unix path style and produce a Path with default file system.
/// You may manipulate its behaviour by setting default_file_system. It also resolves absoluteness of the given path.
pub fn path(str : String) -> Path {
  //todo windows support?
  let components = str.split("/").to_array()
  let path = Path::{ fs: default_file_system, components, absolute: false }
  for root in default_file_system.system_roots() {
    if path.starts_with_path(root) {
      return { ..path, absolute: true }
    }
  }
  path
}

///| Get the
pub fn root(self : Path) -> Path {
  ...
}

///|
/// Return the parent path, or none if has no parent.
pub fn parent(self : Path) -> Path? {
  guard self.components.length() > 1 else { return None }
  return Some(Path::{
    ..self,
    components: self.components[:self.components.length() - 1],
  })
}

///| Resolves another path. For example: path("a").resolve_path(path("b")) equals to path("a/b")  
/// If the other parameter is an absolute path then this method trivially returns other. 
/// If other is an empty path then this method trivially returns this path. 
/// Otherwise this method considers this path to be a directory and resolves the given path against this path. 
/// In the simplest case, the given path does not have a root component, in which case this method joins the given 
/// path to this path and returns a resulting path that ends with the given path.
///  Where the given path has a root component then resolution is highly implementation dependent and therefore unspecified.
pub fn resolve_path(self : Path, another : Path) -> Path {
  let components = self.components
  return Path::{ ..self, components: [..components, ..another.components] }
}

///| Resolves the given path against this path's parent path. This is useful where a file name needs to be replaced with another file name. 
/// For example, suppose that the name separator is "/" and a path represents "dir1/dir2/foo", then invoking this method with the Path "bar" will result in
///  the Path "dir1/dir2/bar". If this path does not have a parent path,
///  or other is absolute, then this method returns other. If other is an empty path then this method returns this path's parent, or where this path doesn't
///  have a parent, the empty path.
pub fn sibling(self : Path, another : String) -> Path {
  guard self.parent() is Some(parent) else { return path(another) }
  parent.resolve(another)
}

///| Returns a path that is this path with redundant name elements eliminated.
/// The precise definition of this method is implementation dependent but in general it derives from this path, a path that does not contain redundant name elements. In many file systems, the "." and ".." are special names used to indicate the current directory and parent directory. In such file systems all occurrences of "." are considered redundant. If a ".." is preceded by a non-".." name then both names are considered redundant (the process to identify such names is repeated until it is no longer applicable).
/// This method does not access the file system; the path may not locate a file that exists. Eliminating ".." and a preceding name from a path may result in the path that locates a different file than the original path. This can arise when the preceding name is a symbolic link.
///|
pub fn clean(self : Path) -> Path {
  ...
}

///|
pub fn is_absolute(self : Path) -> Bool {
  self.absolute
}

///|
pub fn to_absolute(self : Path) -> Path {
  ...
}

///|
pub fn starts_with_path(self : Path, prefix : Path) -> Bool {
  if self.components.length() < prefix.components.length() {
    return false
  }
  for i in 0..<prefix.components.length() {
    if self.components[i] != prefix.components[i] {
      return false
    }
  } else {
    true
  }
}

///|
pub fn starts_with(self : Path, prefix : String) -> Bool {
  self.starts_with_path(path(prefix))
}

///|
pub fn resolve(self : Path, child : String) -> Path {
  self.resolve_path(path(child))
}

///| Constructs a relative path between this path and a given path.
/// Relativization is the inverse of resolution. This method attempts to construct a relative path that when resolved against this path, yields a path that locates the same file as the given path. For example, on UNIX, if this path is "/a/b" and the given path is "/a/b/c/d" then the resulting relative path would be "c/d". Where this path and the given path do not have a root component, then a relative path can be constructed. A relative path cannot be constructed if only one of the paths have a root component. Where both paths have a root component then it is implementation dependent if a relative path can be constructed. If this path and the given path are equal then an empty path is returned.
/// For any two normalized paths p and q, where q does not have a root component,
/// p.relativize(p .resolve(q)).equals(q)
/// When symbolic links are supported, then whether the resulting path, when resolved against this path, yields a path that can be used to locate the same file as other is implementation dependent. For example, if this path is "/a/b" and the given path is "/a/x" then the resulting relative path may be "../x". If "b" is a symbolic link then is implementation dependent if "a/b/../x" would locate the same file as "/a/x".

pub fn relativize(self : Path, other : String) -> Path {
  ...
}

///|
pub fn relativize_path(self : Path, other : Path) -> Path {
  ...
}

///|
pub fn to_unix_path(self : Path) -> String {
  self.components.join("/")
}

///|
let default_file_system : &FileSystem = LocalFileSystem::{  }
