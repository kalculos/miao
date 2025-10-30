# buffer

A simple byte buffer implementation for MoonBit language. It supports both reading and writing Little Endian and Big Endian numbers, with mark/reset and discard/shrink support.

This library was originated from [iceBear67/mbt-bytebuf](https://github.com/iceBear67/mbt-bytebuf). This package is a fork with performance and API improvement.

```MoonBit
test "example" {
  let buf = @buffer.make_unpooled(10)
  buf.write_int_le(0x01020304)
  buf.write_int(0x05060708)
  assert_eq(buf.len(), 8)
  assert_eq(buf.read_int_le(), Some(0x01020304))
  assert_eq(buf.read_int(), Some(0x05060708))
}
```

Codes are fully covered by tests, you can rely on this library safely.

