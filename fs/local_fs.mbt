struct LocalFileSystem {
}

pub impl FileSystem for LocalFileSystem with open_file(self, path, mode, permission~ = 0o644) {
  @fs.open(path.to_unix_path(), mode=mode)
}

