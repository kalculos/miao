test {
  let buf = @bytebuf.make_unpooled(10)

  let varint = read_varint(buf)
}