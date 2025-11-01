///|
pub suberror CompressionError {
  UnexpectedEof
  InvalidZlibHeader
  InvalidGzipHeader
  InvalidChecksum
  UnsupportedWindow
  InvalidBlockType
  InvalidHuffman
  DecodeMismatch
  DistanceTooFar
  LengthOutOfRange
  Internal
} derive(Show)
