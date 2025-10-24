///|
pub(all) enum FileKind {
  RegularFile
  Directory
  Link
  Unknown // Currently unsupported types. Like BlockDevice, Pipe, Socket.
} derive(Eq, Hash, Show)

///|
pub(all) struct FileAttribute {
  last_modified_time : Int64 // unix timestamp ( second )
  last_access_time : Int64
  creation_time : Int64 //todo Instant
  permission : Int
  size : Int64
  kind : FileKind
} derive(Eq, Hash, Show)

///|
pub suberror FileError { // consider merge them into one IOException
  IncorrectKind(path~ : Path, expect~ : FileKind, actual~ : FileKind)
  NotExist(path~ : Path)
  Inaccessible(path~ : Path, error~ : Error, msg~ : String)
}

///|
pub(all) struct FileInfo {
  kind : FileKind
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
  ///| Open a file and return its corresponding FileChannnel
  async open_file(Self, Path, mode : OpenFlags, permission~ : Int) -> &FileChannel
  ///| Check the size of file, if exists. 
  /// Raises an error if the file is not exist.
  async size(Self, Path) -> Int64 raise FileError
  ///| Get attributes of the file. Raise if the file not exists
  async attr(Self, Path) -> FileAttribute raise FileError
  ///| List the content of the file. Raise if the file is not a directory
  async list_directory(Self, Path) -> ArrayView[Path] raise FileError
  ///| Check if we can access the file. Return false if the file is inaccessible or not exist
  async can_access(Self, Path, mode~ : OpenFlags) -> Bool
  ///| Delete a file.
  async delete(Self, Path) -> Unit raise FileError
  async exists(Self, Path) -> Bool
  ///| Resolves a symbol link. Raise if the path is not a symbol link
  async read_symbol_link(Self, Path) -> Path raise FileError
  ///| Move a file to another path. Raise if the operation is failed.
  async move(Self, src : Path, dst : Path, copy_attr~ : Bool) -> Unit raise FileError
  ///| List file roots. An absolute path usually starts with these paths
  system_roots(Self) -> ArrayView[Path]
  ///| Convert a relative path to absolute path using the current working directory
  to_absolute(Self, Path) -> Path
}