///|
pub trait FileChannel: @miao.Channel {
  access(Self) -> AccessMode
  file_system(Self) -> &FileSystem
}

///|
struct LocalFileChannel {
  fs : &FileSystem
  mode: AccessMode
  mut closed: Bool
  file : @asyncfs.File
}

fn _close(self: LocalFileChannel) -> Unit {
  guard !self.closed
  self.closed = true
  self.file.close()
}

///|
impl FileChannel for LocalFileChannel with access(self) {
  self.mode
}

///|
impl FileChannel for LocalFileChannel with file_system(self) {
  self.fs
}

///|
impl @asyncio.Writer for LocalFileChannel with write_once(self, bytes, offset~, len~) -> Int {
  self.file.write_once(bytes, offset~, len~)
}

impl @miao.Writer for LocalFileChannel with can_write(self) {
  self.mode == ReadOnly
}

impl @miao.Writer for LocalFileChannel with close(self) {
  self._close()
}
impl @miao.Channel for LocalFileChannel with close(self) {
  self._close()
}

impl @miao.Reader for LocalFileChannel with can_read(self) -> Bool {
  self.mode != WriteOnly
}

impl @miao.Reader for LocalFileChannel with close(self) {
  self._close()
}

pub impl @asyncio.Reader for LocalFileChannel with read(
  self,
  arr,
  offset? = 0,
  max_len? = arr.length() - offset,
) -> Int {
  self.file.read(arr, offset~, max_len~)
}