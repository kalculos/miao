///|
let default_file_system : Ref[&FileSystem?] = Ref::new(None)

///|
pub fn set_default_fs(fs : &FileSystem) -> Unit {
  default_file_system.val = Some(fs)
}

///|
/// A Path is an immutable object that associates a filepath string and its corresponding filesystem, to unify access between real filesystems and virtual file systems.
/// Path consists of components. Like "a/b" where the components are ["a", "b"]. for root folder, it has no component.("/"). Path can also used to describe relative relationships.
/// Implementations of this interface are immutable and safe for use by multiple concurrent threads.
/// 
/// Absolute Path: An absolute path is complete in that it doesn't need to be combined with other path information in order to locate a file.
/// Whether a path is absolute or not is determined on construction.
/// 
/// It derives Eq, Show and Hash. All are delegated to its unix path representation
/// 
pub(all) struct Path {
  fs : &FileSystem
  priv absolute : Bool
  priv components : ArrayView[StringView]
}

///|
pub impl Show for Path with output(self, out) {
  self.to_unix_path().output(out)
}

///|
pub impl Hash for Path with hash(self) {
  self.to_unix_path().hash()
}

///|
pub impl Hash for Path with hash_combine(self, hasher) {
  self.to_unix_path().hash_combine(hasher)
}

///|
pub impl Eq for Path with equal(self, another) {
  let a = self.components
  let b = another.components
  guard a.length() == b.length() else { return false }
  for i = 0; i < a.length(); i = i + 1 {
    guard a[i] == b[i] else { return false }
  } else {
    true
  }
}

///|
/// A factory of path. It parses the input in unix path style and produce a Path with default file system.
/// You may manipulate its behaviour by hijacking runtime. It also resolves absoluteness of the given path.
pub fn path(
  str : String,
  using_fs? : &FileSystem = default_file_system.val.unwrap(),
) -> Path { // todo illegal path detection?
  //todo windows support?
  let components = str.split("/").to_array()
  let path = Path::{ fs: using_fs, components, absolute: false }
  for root in using_fs.system_roots() {
    if path.starts_with_path(root) {
      return { ..path, absolute: true }
    }
  }
  path
}

///|
/// Get the root path for this path's filesystem
pub fn Path::root(self : Path) -> Path {
  let roots = self.fs.system_roots()
  if roots.length() == 0 {
    // Fallback to root with no components
    return Path::{ fs: self.fs, components: [], absolute: true }
  }

  // Find the matching root for this path
  for root in roots {
    if self.starts_with_path(root) {
      return root
    }
  }

  // If no matching root found, return the first root or fallback
  return Path::{ ..self, components: [], absolute: true }
}

///|
/// Return the parent path, or none if has no parent.
pub fn Path::parent(self : Path) -> Path? {
  guard self.components.length() > 1 else { return None }
  return Some(Path::{
    ..self,
    components: self.components[:self.components.length() - 1],
  })
}

///|
/// Resolves another path. For example: path("a").resolve_path(path("b")) equals to path("a/b")  
/// If the other parameter is an absolute path then this method trivially returns other. 
/// If other is an empty path then this method trivially returns this path. 
/// Otherwise this method considers this path to be a directory and resolves the given path against this path. 
/// In the simplest case, the given path does not have a root component, in which case this method joins the given 
/// path to this path and returns a resulting path that ends with the given path.
///  Where the given path has a root component then resolution is highly implementation dependent and therefore unspecified.
pub fn Path::resolve_path(self : Path, another : Path) -> Path {
  let components = self.components
  return Path::{ ..self, components: [..components, ..another.components] }
}

///|
/// Resolves the given path against this path's parent path. This is useful where a file name needs to be replaced with another file name. 
/// For example, suppose that the name separator is "/" and a path represents "dir1/dir2/foo", then invoking this method with the Path "bar" will result in
///  the Path "dir1/dir2/bar". If this path does not have a parent path,
///  or other is absolute, then this method returns other. If other is an empty path then this method returns this path's parent, or where this path doesn't
///  have a parent, the empty path.
pub fn Path::sibling(self : Path, another : String) -> Path {
  guard self.parent() is Some(parent) else { return path(another) }
  parent.resolve(another)
}

///| Returns a path that is this path with redundant name elements eliminated.
/// The precise definition of this method is implementation dependent but in general it derives from this path, a path that does not contain redundant name elements. In many file systems, the "." and ".." are special names used to indicate the current directory and parent directory. In such file systems all occurrences of "." are considered redundant. If a ".." is preceded by a non-".." name then both names are considered redundant (the process to identify such names is repeated until it is no longer applicable).
/// This method does not access the file system; the path may not locate a file that exists. Eliminating ".." and a preceding name from a path may result in the path that locates a different file than the original path. This can arise when the preceding name is a symbolic link.

///|

///|
pub fn Path::clean(self : Path) -> Path {
  let stack = Array::new()
  for component in self.components {
    match component.to_string() {
      "." => ignore(()) // skip current directory marker
      ".." =>
        // remove last non-".." entry if exists
        if stack.length() > 0 && stack[stack.length() - 1] != ".." {
          ignore(stack.pop())
        } else {
          // keep ".." if we can't remove a previous component
          stack.push("..")
        }
      "" => ignore(()) // skip empty components
      str => stack.push(str)
    }
  }
  Path::{ ..self, components: stack.map(it => it[:]) }
}

///|
pub fn Path::is_absolute(self : Path) -> Bool {
  self.absolute
}

///|
pub fn Path::to_absolute(self : Path) -> Path {
  if self.absolute {
    self
  } else {
    let cwd = self.fs.cwd()
    cwd.resolve_path(self).clean()
  }
}

///|
pub fn Path::starts_with_path(self : Path, prefix : Path) -> Bool {
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
pub fn Path::starts_with(self : Path, prefix : String) -> Bool {
  self.starts_with_path(path(prefix))
}

///|
pub fn Path::resolve(self : Path, child : String) -> Path {
  self.resolve_path(path(child))
}

///|
/// Constructs a relative path between this path and a given path.
/// Relativization is the inverse of resolution. This method attempts to construct a relative path that when resolved against this path, yields a path that locates the same file as the given path. For example, on UNIX, if this path is "/a/b" and the given path is "/a/b/c/d" then the resulting relative path would be "c/d". Where this path and the given path do not have a root component, then a relative path can be constructed. A relative path cannot be constructed if only one of the paths have a root component. Where both paths have a root component then it is implementation dependent if a relative path can be constructed. If this path and the given path are equal then an empty path is returned.
/// For any two normalized paths p and q, where q does not have a root component,
/// p.relativize(p .resolve(q)).equals(q)
/// When symbolic links are supported, then whether the resulting path, when resolved against this path, yields a path that can be used to locate the same file as other is implementation dependent. For example, if this path is "/a/b" and the given path is "/a/x" then the resulting relative path may be "../x". If "b" is a symbolic link then is implementation dependent if "a/b/../x" would locate the same file as "/a/x".
pub fn Path::relativize(self : Path, other : String) -> Path {
  self.relativize_path(path(other))
}

///|
pub fn Path::relativize_path(self : Path, other : Path) -> Path {
  // Both paths must be absolute or both must be relative
  if self.absolute != other.absolute {
    return other
  }

  // If paths have same components, return empty path
  if self.components.length() == other.components.length() {
    let mut same = true
    for i in 0..<self.components.length() {
      if self.components[i] != other.components[i] {
        same = false
        break
      }
    }
    if same {
      let empty : ArrayView[StringView] = []
      return Path::{ ..self, components: empty, absolute: false }
    }
  }

  // Clean both paths
  let base = self.clean()
  let target = other.clean()

  // Find common prefix length
  let mut common_length = 0
  let min_len = if base.components.length() < target.components.length() {
    base.components.length()
  } else {
    target.components.length()
  }
  while common_length < min_len &&
        base.components[common_length] == target.components[common_length] {
    common_length = common_length + 1
  }

  // Build the relative path
  let up_count = base.components.length() - common_length
  let result : Array[StringView] = []

  // Add ".." for each remaining component in base path
  for i in 0..<up_count {
    result.push("..")
  }

  // Add remaining components from target path
  for i in common_length..<target.components.length() {
    result.push(target.components[i])
  }
  Path::{ ..self, components: result, absolute: false }
}

///|
pub fn Path::to_unix_path(self : Path) -> String {
  self.components.join("/")
}
