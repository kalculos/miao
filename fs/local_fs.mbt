struct LocalFileSystem {
}

pub impl FileSystem for LocalFileSystem with is_read_only(self) {
  false // todo
}

pub impl FileSystem for LocalFileSystem with open_file(self, path, mode~ = 0o644) {
  @fs.open(path.to_unix_path(), mode=mode)
}

