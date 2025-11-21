///| Path Tests

///|
/// Test basic path creation
test "path basic" {
  let fs = MemFileSystem::new()
  let p = path_fs("/a/b/c", using_fs=fs)
  inspect(p.to_unix_path(), content="a/b/c")
  inspect(p.is_absolute(), content="true")
}

///|
/// Test root path
test "path root" {
  let fs = MemFileSystem::new()
  let p = path_fs("/", using_fs=fs)
  inspect(p.to_unix_path(), content="")
  inspect(p.is_absolute(), content="true")
}

///|
/// Test empty path
test "path empty" {
  let fs = MemFileSystem::new()
  let p = path_fs("", using_fs=fs)
  inspect(p.to_unix_path(), content="")
  inspect(p.is_absolute(), content="true")
}

///|
/// Test relative path
test "path relative" {
  let fs = MemFileSystem::new()
  let p = path_fs("a/b", using_fs=fs)
  inspect(p.to_unix_path(), content="a/b")
  inspect(p.is_absolute(), content="true")
}

///|
/// Test path with multiple slashes
test "path multiple slashes" {
  let fs = MemFileSystem::new()
  let p = path_fs("/a//b///c", using_fs=fs)
  inspect(p.to_unix_path(), content="a/b/c")
}

///|
/// Test path with trailing slash
test "path trailing slash" {
  let fs = MemFileSystem::new()
  let p = path_fs("/a/b/", using_fs=fs)
  inspect(p.to_unix_path(), content="a/b")
}

///|
/// Test Path::clean with dots
test "Path::clean with dots" {
  let fs = MemFileSystem::new()
  let p = path_fs("/a/./b", using_fs=fs)
  inspect(p.clean().to_unix_path(), content="a/b")
}

///|
/// Test Path::clean with double dots
test "Path::clean with double dots" {
  let fs = MemFileSystem::new()
  let p = path_fs("/a/b/../c", using_fs=fs)
  inspect(p.clean().to_unix_path(), content="a/c")
}

///|
/// Test Path::clean with multiple double dots
test "Path::clean with multiple double dots" {
  let fs = MemFileSystem::new()
  let p = path_fs("/a/b/c/../../d", using_fs=fs)
  inspect(p.clean().to_unix_path(), content="a/d")
}

///|
/// Test Path::clean at end
test "Path::clean at end" {
  let fs = MemFileSystem::new()
  let p = path_fs("/a/b/..", using_fs=fs)
  inspect(p.clean().to_unix_path(), content="a")
}

///|
/// Test Path::parent basic
test "Path::parent basic" {
  let fs = MemFileSystem::new()
  let p = path_fs("/a/b/c", using_fs=fs)
  match p.parent() {
    Some(parent) => inspect(parent.to_unix_path(), content="a/b")
    None => assert_false(true, msg="Expected parent")
  }
}

///|
/// Test Path::parent of root
test "Path::parent of root" {
  let fs = MemFileSystem::new()
  let p = path_fs("/", using_fs=fs)
  match p.parent() {
    Some(_) => assert_false(true, msg="Root should not have parent")
    None => ()
  }
}

///|
/// Test Path::parent single component
test "Path::parent single component" {
  let fs = MemFileSystem::new()
  let p = path_fs("/a", using_fs=fs)
  // Absolute single-component paths like "/a" have parent "/"
  match p.parent() {
    Some(parent) =>
      inspect(
        parent.to_string(),
        content=(
          #|""
        ),
      )
    None => assert_false(true, msg="Absolute path /a should have parent /")
  }
}

///|
/// Test Path::resolve basic
test "Path::resolve basic" {
  let fs = MemFileSystem::new()
  let p = path_fs("/a/b", using_fs=fs)
  let resolved = p.resolve("c/d")
  inspect(resolved.to_unix_path(), content="a/b/c/d")
}

///|
/// Test Path::resolve with absolute
test "Path::resolve with absolute" {
  let fs = MemFileSystem::new()
  let p = path_fs("/a/b", using_fs=fs)
  let resolved = p.resolve("/c/d")
  inspect(resolved.to_unix_path(), content="a/b/c/d")
}

///|
/// Test Path::resolve_path
test "Path::resolve_path" {
  let fs = MemFileSystem::new()
  let p1 = path_fs("/a", using_fs=fs)
  let p2 = path_fs("b/c", using_fs=fs)
  let resolved = p1.resolve_path(p2)
  inspect(resolved.to_unix_path(), content="a/b/c")
}

///|
/// Test Path::sibling
test "Path::sibling" {
  let fs = MemFileSystem::new()
  let p = path_fs("/a/b/c", using_fs=fs)
  let sibling = p.sibling("d")
  inspect(sibling.to_unix_path(), content="a/b/d")
}

///|
/// Test Path::sibling without parent
test "Path::sibling without parent" {
  let fs = MemFileSystem::new()
  let p = path_fs("/a", using_fs=fs)
  let sibling = p.sibling("b")
  inspect(sibling.to_unix_path(), content="b")
}

///|
/// Test Path::relativize basic
test "Path::relativize basic" {
  let fs = MemFileSystem::new()
  let base = path_fs("/a/b", using_fs=fs)
  let target = path_fs("/a/b/c/d", using_fs=fs)
  let rel = base.relativize_path(target)
  inspect(rel.to_unix_path(), content="c/d")
}

///|
/// Test Path::relativize siblings
test "Path::relativize siblings" {
  let fs = MemFileSystem::new()
  let base = path_fs("/a/b", using_fs=fs)
  let target = path_fs("/a/c", using_fs=fs)
  let rel = base.relativize_path(target)
  inspect(rel.to_unix_path(), content="../c")
}

///|
/// Test Path::relativize same path
test "Path::relativize same path" {
  let fs = MemFileSystem::new()
  let p = path_fs("/a/b/c", using_fs=fs)
  let rel = p.relativize_path(p)
  inspect(rel.to_unix_path(), content="")
}

///|
/// Test Path::to_absolute
test "Path::to_absolute from relative" {
  let fs = MemFileSystem::new()
  let p = path_fs("a/b", using_fs=fs)
  let abs = p.to_absolute()
  inspect(abs.is_absolute(), content="true")
}

///|
/// Test Path::to_absolute from absolute
test "Path::to_absolute from absolute" {
  let fs = MemFileSystem::new()
  let p = path_fs("/a/b", using_fs=fs)
  let abs = p.to_absolute()
  inspect(abs.to_unix_path(), content="a/b")
  inspect(abs.is_absolute(), content="true")
}

///|
/// Test Path::starts_with
test "Path::starts_with true" {
  let fs = MemFileSystem::new()
  let p = path_fs("/a/b/c", using_fs=fs)
  inspect(p.starts_with("/a/b"), content="true")
}

///|
/// Test Path::starts_with false
test "Path::starts_with false" {
  let fs = MemFileSystem::new()
  let p = path_fs("/a/b/c", using_fs=fs)
  inspect(p.starts_with("/a/c"), content="false")
}

///|
/// Test Path equality
test "Path equality same" {
  let fs = MemFileSystem::new()
  let p1 = path_fs("/a/b", using_fs=fs)
  let p2 = path_fs("/a/b", using_fs=fs)
  inspect(p1 == p2, content="true")
}

///|
/// Test Path equality different
test "Path equality different" {
  let fs = MemFileSystem::new()
  let p1 = path_fs("/a/b", using_fs=fs)
  let p2 = path_fs("/a/c", using_fs=fs)
  inspect(p1 == p2, content="false")
}

///|
/// Test Path::root
test "Path::root" {
  let fs = MemFileSystem::new()
  let p = path_fs("/a/b/c", using_fs=fs)
  let root = p.root()
  inspect(root.to_unix_path(), content="")
  inspect(root.is_absolute(), content="true")
}
