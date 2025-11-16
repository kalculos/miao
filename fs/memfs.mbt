///|
struct MemEntry {
  name : String
  kind : FileKind
  content : Array[Byte]
  children : Map[String, Ref[MemEntry]]
  target : Path?
  mut last_modified : @time.Instant
  mut last_access : @time.Instant
  creation_time : @time.Instant
}

///|
fn mementry_new_dir(name : String) -> MemEntry {
  let now = @time.Instant::now()
  MemEntry::{
    name,
    kind: FileKind::Directory,
    content: [],
    children: Map::new(),
    target: None,
    last_modified: now,
    last_access: now,
    creation_time: now,
  }
}

///|
fn mementry_new_file(name : String) -> MemEntry {
  let now = @time.Instant::now()
  MemEntry::{
    name,
    kind: FileKind::RegularFile,
    content: [],
    children: Map::new(),
    target: None,
    last_modified: now,
    last_access: now,
    creation_time: now,
  }
}

///|
fn mementry_new_link(name : String, target : Path) -> MemEntry {
  let now = @time.Instant::now()
  MemEntry::{
    name,
    kind: FileKind::Link,
    content: [],
    children: Map::new(),
    target: Some(target),
    last_modified: now,
    last_access: now,
    creation_time: now,
  }
}

///|
pub struct MemFileSystem {
  id : String
  root : Ref[MemEntry]
}

///|
pub fn MemFileSystem::new(id? : String = "inmem") -> MemFileSystem {
  MemFileSystem::{ id, root: { val: mementry_new_dir("") } }
}

///|
/// Helper: split path into components (no clean to avoid recursion)
fn split_components(p : Path) -> Array[String] {
  let res : Array[String] = []
  for c in p.components {
    let s = c.to_string()
    res.push(s)
  }
  res
}

///|
/// Find node, optionally creating intermediate directories
fn MemFileSystem::find_ref(
  self : MemFileSystem,
  path : Path,
  create_dirs? : Bool = false,
) -> Ref[MemEntry]? {
  // Don't call to_absolute() to avoid infinite recursion through cwd()
  let comps = split_components(path)
  let mut node_ref = self.root
  if comps.length() == 0 {
    return Some(node_ref)
  }
  for i in 0..<comps.length() {
    let name = comps[i]
    match node_ref.val.children.get(name) {
      Some(child_ref) => node_ref = child_ref
      None =>
        if create_dirs {
          let dir = mementry_new_dir(name)
          let new_ref : Ref[MemEntry] = { val: dir }
          node_ref.val.children.set(name, new_ref)
          node_ref = new_ref
        } else {
          return None
        }
    }
  }
  Some(node_ref)
}

///|
/// Find node (returns value copy)
fn MemFileSystem::find(
  self : MemFileSystem,
  path : Path,
  create_dirs? : Bool = false,
) -> MemEntry? {
  match self.find_ref(path, create_dirs~) {
    Some(r) => Some(r.val)
    None => None
  }
}

///|
fn build_attr(entry : MemEntry) -> FileAttribute {
  FileAttribute::{
    last_modified_time: entry.last_modified,
    last_access_time: entry.last_access,
    creation_time: entry.creation_time,
    permission: 0UL,
    size: entry.content.length().to_uint64(),
    kind: entry.kind,
  }
}

///|
struct MemFileChannel {
  entry_ref : Ref[MemEntry]
  mut pos : Int
  mut closed : Bool
  access : OpenFlags
  path : Path
}

///|
fn memfilechannel_new(
  entry_ref : Ref[MemEntry],
  flag : OpenFlags,
  path : Path,
) -> MemFileChannel {
  MemFileChannel::{ entry_ref, pos: 0, closed: false, access: flag, path }
}

///|
pub impl FileChannel for MemFileChannel with access(self) {
  self.access
}

///|
pub impl FileChannel for MemFileChannel with info(self) {
  FileInfo::{ attribute: build_attr(self.entry_ref.val), path: self.path }
}

///|
pub impl @io.Channel for MemFileChannel with close(self) {
  self.closed = true
}

///|
pub impl @io.Channel for MemFileChannel with is_closed(self) {
  self.closed
}

///|
pub impl @io.Reader for MemFileChannel with read(self, dst, off, len) {
  guard !self.closed else { return 0 }
  guard self.access.has_read() else {
    raise fail("file not opened for reading")
  }
  let entry = self.entry_ref.val
  let avail = entry.content.length() - self.pos
  if avail <= 0 {
    return 0
  }
  let toread = if avail < len { avail } else { len }
  for i in 0..<toread {
    dst[off + i] = entry.content[self.pos + i]
  }
  self.pos = self.pos + toread
  self.entry_ref.val.last_access = @time.Instant::now()
  toread
}

///|
pub impl @io.Writer for MemFileChannel with write(self, arr, off, len) {
  guard !self.closed else { return 0 }
  guard self.access.has_write() else {
    raise fail("file not opened for writing")
  }
  let entry = self.entry_ref.val
  // If append mode, always write at end
  if self.access.is_append() {
    self.pos = entry.content.length()
  }
  // ensure capacity
  let needed = self.pos + len
  while entry.content.length() < needed {
    entry.content.push(0)
  }
  for i in 0..<len {
    entry.content[self.pos + i] = arr[off + i]
  }
  self.pos = self.pos + len
  self.entry_ref.val.last_modified = @time.Instant::now()
  self.entry_ref.val.last_access = @time.Instant::now()
  len
}

///|
pub impl @io.Writer for MemFileChannel with close(self) {
  self.closed = true
}

///|
pub impl @io.Writer for MemFileChannel with is_closed(self) {
  self.closed
}

///|
pub impl @io.Reader for MemFileChannel with close(self) {
  self.closed = true
}

///|
pub impl @io.Reader for MemFileChannel with is_closed(self) {
  self.closed
}

///|
pub impl FileSystem for MemFileSystem with id(self) {
  self.id()
}

///|
pub impl FileSystem for MemFileSystem with open_file(
  self,
  path,
  flag,
  mode~,
  follow_links?,
) {
  ignore(mode)
  ignore(follow_links)
  // create parent directories if needed when create flag present
  let p = path
  let parent = p.parent().unwrap_or(p.root())
  // ensure parent directory exists if create flag set
  let create = flag.is_create()
  if create {
    self.find(parent, create_dirs=true) |> ignore
  }
  match self.find_ref(p, create_dirs=false) {
    Some(node_ref) => {
      // File exists
      if create && flag.is_exclusive() {
        return Err(FileError::AlreadyExists(msg="file already exists (exclusive flag)"))
      }
      let node = node_ref.val
      // Truncate if flag is set
      if flag.is_truncate() {
        node.content.clear()
      }
      Ok(memfilechannel_new(node_ref, flag, p) as &FileChannel)
    }
    None =>
      if create {
        let name = p.components[p.components.length() - 1]
        let file = mementry_new_file(name.to_string())
        let file_ref : Ref[MemEntry] = { val: file }
        match self.find_ref(parent, create_dirs=true) {
          Some(parent_ref) => {
            parent_ref.val.children.set(file.name, file_ref)
            Ok(memfilechannel_new(file_ref, flag, p) as &FileChannel)
          }
          None => Err(FileError::NotFound(msg="parent not found"))
        }
      } else {
        Err(FileError::NotFound(msg="file not found"))
      }
  }
}

///|
pub impl FileSystem for MemFileSystem with attr(self, path, follow_links?) {
  ignore(follow_links)
  match self.find(path, create_dirs=false) {
    Some(node) => Ok(build_attr(node))
    None => Err(FileError::NotFound(msg="file not found"))
  }
}

///|
pub impl FileSystem for MemFileSystem with list_directory(self, path) {
  match self.find(path, create_dirs=false) {
    Some(node) if node.kind == FileKind::Directory => {
      let res : Array[Path] = []
      node.children.each(fn(k, _) { res.push(path.resolve(k)) })
      Ok(res)
    }
    Some(_) => Err(FileError::UnexpectedKind(msg="not a directory"))
    None => Err(FileError::NotFound(msg="path not found"))
  }
}

///|
pub impl FileSystem for MemFileSystem with can_access(self, path, flag) {
  ignore(flag)
  match self.find(path, create_dirs=false) {
    Some(_) => true
    None => false
  }
}

///|
pub impl FileSystem for MemFileSystem with delete(self, path) {
  let p = path
  let parent = match p.parent() {
    Some(v) => v
    None => return Err(FileError::PermissionDenied(msg="cannot delete root"))
  }
  let parent_node = match self.find(parent, create_dirs=false) {
    Some(v) => v
    None => return Err(FileError::NotFound(msg="no parent"))
  }
  let name = p.components[p.components.length() - 1].to_string()
  match parent_node.children.get(name) {
    Some(node_ref) => {
      let node = node_ref.val
      if node.kind == FileKind::Directory && node.children.length() > 0 {
        return Err(FileError::UnexpectedKind(msg="directory not empty"))
      }
      parent_node.children.remove(name) |> ignore
      Ok(())
    }
    None => Err(FileError::NotFound(msg="not found"))
  }
}

///|
pub impl FileSystem for MemFileSystem with exists(self, path) {
  self.can_access(path, AccessFlags::new())
}

///|
pub impl FileSystem for MemFileSystem with read_symbol_link(self, path) {
  match self.find(path, create_dirs=false) {
    Some(node) if node.kind == FileKind::Link => Ok(node.target.unwrap())
    Some(_) => Err(FileError::InvalidPath(msg="not a symlink"))
    None => Err(FileError::NotFound(msg="path not found"))
  }
}

///|
pub impl FileSystem for MemFileSystem with rename(self, src, dst, copy_attr~) {
  ignore(copy_attr)
  let s = src
  let d = dst
  let sparent = match s.parent() {
    Some(v) => v
    None => return Err(FileError::PermissionDenied(msg="cannot rename root"))
  }
  let dparent = match d.parent() {
    Some(v) => v
    None => return Err(FileError::PermissionDenied(msg="cannot rename to root"))
  }
  let snode_parent = match self.find(sparent, create_dirs=false) {
    Some(v) => v
    None => return Err(FileError::NotFound(msg="src parent not found"))
  }
  // Don't auto-create destination parent - it must exist
  let dnode_parent = match self.find(dparent, create_dirs=false) {
    Some(v) => v
    None => return Err(FileError::NotFound(msg="dst parent not found"))
  }
  let name = s.components[s.components.length() - 1].to_string()
  match snode_parent.children.get(name) {
    Some(node) => {
      snode_parent.children.remove(name) |> ignore
      dnode_parent.children.set(
        d.components[d.components.length() - 1].to_string(),
        node,
      )
      Ok(())
    }
    None => Err(FileError::NotFound(msg="src not found"))
  }
}

///|
pub impl FileSystem for MemFileSystem with real_path(self, path) {
  ignore(self)
  Ok(path)
}

///|
pub impl FileSystem for MemFileSystem with cwd(self) {
  // Create path directly to avoid recursion through path() -> system_roots()
  Path::{ fs: self, components: [], absolute: true }
}

///|
pub impl FileSystem for MemFileSystem with system_roots(self) {
  // Create path directly to avoid recursion
  [Path::{ fs: self, components: [], absolute: true }]
}
