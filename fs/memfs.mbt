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
  root : Ref[MemEntry]
}

///|
pub fn MemFileSystem::new() -> MemFileSystem {
  MemFileSystem::{ root: { val: mementry_new_dir("") } }
}

///|
/// Helper: split path into components (no clean to avoid recursion)
fn split_components(p : Path) -> Array[String] {
  let res : Array[String] = []
  for c in p.components {
    let s = c.to_string()
    // Filter out empty components (from paths like "/" which split to ["", ""])
    if s.length() > 0 {
      res.push(s)
    }
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
  entry : MemEntry
  mut pos : Int
  mut closed : Bool
  access : OpenFlags
  info : FileInfo
}

///|
fn memfilechannel_new(
  entry : MemEntry,
  flag : OpenFlags,
  path : Path,
) -> MemFileChannel {
  MemFileChannel::{
    entry,
    pos: 0,
    closed: false,
    access: flag,
    info: FileInfo::{ attribute: build_attr(entry), path },
  }
}

///|
impl FileChannel for MemFileChannel with access(self) {
  self.access
}

///|
impl FileChannel for MemFileChannel with info(self) {
  self.info
}

///|
impl @io.Channel for MemFileChannel with close(self) {
  self.closed = true
}

///|
impl @io.Channel for MemFileChannel with is_closed(self) {
  self.closed
}

///|
impl @io.Reader for MemFileChannel with read(self, dst, off, len) {
  guard !self.closed else { return 0 }
  let avail = self.entry.content.length() - self.pos
  if avail <= 0 {
    return 0
  }
  let toread = if avail < len { avail } else { len }
  for i in 0..<toread {
    dst[off + i] = self.entry.content[self.pos + i]
  }
  self.pos = self.pos + toread
  self.entry.last_access = @time.Instant::now()
  toread
}

///|
impl @io.Writer for MemFileChannel with write(self, arr, off, len) {
  guard !self.closed else { return 0 }
  // ensure capacity
  let needed = self.pos + len
  while self.entry.content.length() < needed {
    self.entry.content.push(0)
  }
  for i in 0..<len {
    self.entry.content[self.pos + i] = arr[off + i]
  }
  self.pos = self.pos + len
  self.entry.last_modified = @time.Instant::now()
  self.entry.last_access = @time.Instant::now()
  len
}

///|
impl @io.Writer for MemFileChannel with close(self) {
  self.closed = true
}

///|
impl @io.Writer for MemFileChannel with is_closed(self) {
  self.closed
}

///|
impl @io.Reader for MemFileChannel with close(self) {
  self.closed = true
}

///|
impl @io.Reader for MemFileChannel with is_closed(self) {
  self.closed
}

///|
impl FileSystem for MemFileSystem with open_file(
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
  match self.find(p, create_dirs=false) {
    Some(node) => memfilechannel_new(node, flag, p)
    None =>
      if create {
        let name = p.components[p.components.length() - 1]
        let file = mementry_new_file(name.to_string())
        let parent_node = self.find(parent, create_dirs=true).unwrap()
        parent_node.children.set(file.name, { val: file })
        memfilechannel_new(file, flag, p)
      } else {
        raise fail("file not found")
      }
  }
}

///|
impl FileSystem for MemFileSystem with attr(self, path, follow_links?) {
  ignore(follow_links)
  match self.find(path, create_dirs=false) {
    Some(node) => build_attr(node)
    None => raise fail("file not found")
  }
}

///|
impl FileSystem for MemFileSystem with list_directory(self, path) {
  match self.find(path, create_dirs=false) {
    Some(node) if node.kind == FileKind::Directory => {
      let res : Array[Path] = []
      node.children.each(fn(k, _) { res.push(path.resolve(k)) })
      res
    }
    _ => raise fail("not a directory")
  }
}

///|
impl FileSystem for MemFileSystem with can_access(self, path, flag) {
  ignore(flag)
  match self.find(path, create_dirs=false) {
    Some(_) => true
    None => false
  }
}

///|
impl FileSystem for MemFileSystem with delete(self, path) {
  let p = path
  let parent = match p.parent() {
    Some(v) => v
    None => raise fail("cannot delete root")
  }
  let parent_node = match self.find(parent, create_dirs=false) {
    Some(v) => v
    None => raise fail("no parent")
  }
  let name = p.components[p.components.length() - 1].to_string()
  match parent_node.children.get(name) {
    Some(node_ref) => {
      let node = node_ref.val
      if node.kind == FileKind::Directory && node.children.length() > 0 {
        raise fail("directory not empty")
      }
      parent_node.children.remove(name) |> ignore
    }
    None => raise fail("not found")
  }
}

///|
impl FileSystem for MemFileSystem with exists(self, path) {
  self.can_access(path, AccessFlags::new())
}

///|
impl FileSystem for MemFileSystem with read_symbol_link(self, path) {
  match self.find(path, create_dirs=false) {
    Some(node) if node.kind == FileKind::Link => node.target.unwrap()
    _ => raise fail("not a symlink")
  }
}

///|
impl FileSystem for MemFileSystem with rename(self, src, dst, copy_attr~) {
  ignore(copy_attr)
  let s = src
  let d = dst
  let sparent = match s.parent() {
    Some(v) => v
    None => raise fail("cannot rename root")
  }
  let dparent = match d.parent() {
    Some(v) => v
    None => raise fail("cannot rename to root")
  }
  let snode_parent = match self.find(sparent, create_dirs=false) {
    Some(v) => v
    None => raise fail("src parent not found")
  }
  let dnode_parent = self.find(dparent, create_dirs=true).unwrap()
  let name = s.components[s.components.length() - 1].to_string()
  match snode_parent.children.get(name) {
    Some(node) => {
      snode_parent.children.remove(name) |> ignore
      dnode_parent.children.set(
        d.components[d.components.length() - 1].to_string(),
        node,
      )
    }
    None => raise fail("src not found")
  }
}

///|
impl FileSystem for MemFileSystem with real_path(self, path) {
  ignore(self)
  path
}

///|
impl FileSystem for MemFileSystem with cwd(self) {
  // Create path directly to avoid recursion through path() -> system_roots()
  Path::{ fs: self, components: [], absolute: true }
}

///|
impl FileSystem for MemFileSystem with system_roots(self) {
  // Create path directly to avoid recursion
  [Path::{ fs: self, components: [], absolute: true }]
}
