///|
pub(all) suberror FileError {
  NotFound(msg~ : String)
  PermissionDenied(msg~ : String)
  AlreadyExists(msg~ : String)
  UnexpectedKind(msg~ : String)
  InvalidPath(msg~ : String)
  IoError(msg~ : String)
} derive(Show, Eq, Hash)

///|
pub(all) enum FileKind {
  RegularFile
  Directory
  Link
  Unknown // Currently unsupported types. Like BlockDevice, Pipe, Socket.
} derive(Eq, Hash, Show)

///|
pub(all) struct FileAttribute {
  last_modified_time : @time.Instant
  last_access_time : @time.Instant
  creation_time : @time.Instant
  permission : UInt64
  size : UInt64
  kind : FileKind
} derive(Eq, Hash, Show)

///|
pub(all) struct FileInfo {
  attribute : FileAttribute
  path : Path
}

///|
pub(open) trait FileChannel: @io.Channel {
  access(Self) -> OpenFlags
  info(Self) -> FileInfo
}

///|
/// A FileSystem handles I/O operations to files that is associated with a unique
///  string (path) given from the filesystem. A FileSystem does not strictly related to a specific disk partition or 
/// any filesystem softwares. For example, the whole accessible local storage is considered as a FileSystem.
pub(open) trait FileSystem {
  id(Self) -> String
  ///| Open a file and return its corresponding FileChannnel
  async open_file(
    Self,
    Path,
    flag : OpenFlags,
    mode~ : AccessFlags,
    follow_links? : Bool,
  ) -> Result[&FileChannel, FileError]
  ///| Get attributes of the file. Returns error if the file not exists
  async attr(Self, Path, follow_links? : Bool) -> Result[
    FileAttribute,
    FileError,
  ]
  ///| List the content of the file. Returns error if the file is not a directory
  async list_directory(Self, Path) -> Result[ArrayView[Path], FileError]
  ///| Check if we can access the file. Return false if the file is inaccessible or not exist
  async can_access(Self, Path, flag : AccessFlags) -> Bool
  ///| Delete a file.
  async delete(Self, Path) -> Result[Unit, FileError]
  async exists(Self, Path) -> Bool
  ///| Resolves a symbol link. Returns error if the path is not a symbol link
  async read_symbol_link(Self, Path) -> Result[Path, FileError]
  ///| Move a file to another path. Returns error if the operation is failed.
  async rename(Self, src : Path, dst : Path, copy_attr~ : Bool) -> Result[
    Unit,
    FileError,
  ]
  ///| Returns a path with all symbolic links and path redirections resolved.
  async real_path(Self, path : Path) -> Result[Path, FileError]
  ///| The current working directory.
  cwd(Self) -> Path
  ///| List file roots. An absolute path usually starts with these paths
  system_roots(Self) -> ArrayView[Path]
}
