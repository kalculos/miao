///| Tests for DNS codec (encoding and decoding)

test "encode_header basic" {
  let header = Header::new(
    0x1234,
    MessageType::Query,
    OpCode::Query,
    false,
    false,
    true,
    false,
    0,
    ResponseCode::NoError,
    1,
    0,
    0,
    0
  )
  
  let buf = @buffer.HeapByteBuf::new(12)
  encode_header(header, buf as &@buffer.Buffer)
  
  inspect(buf.readable_bytes(), content="12")
  
  // Read back the bytes
  let data : FixedArray[Byte] = FixedArray::make(12, 0)
  buf.read(data, 0, 12) |> ignore
  
  // Check ID bytes
  inspect(data[0].to_int(), content="18") // 0x12
  inspect(data[1].to_int(), content="52") // 0x34
  
  // Check flags - should have RD bit set (0x0100)
  inspect(data[2].to_int(), content="1") // 0x01
  inspect(data[3].to_int(), content="0") // 0x00
}

test "decode_header basic" {
  let data : FixedArray[Byte] = [
    0x12, 0x34, // ID
    0x01, 0x00, // Flags: RD set
    0x00, 0x01, // QDCOUNT
    0x00, 0x00, // ANCOUNT
    0x00, 0x00, // NSCOUNT
    0x00, 0x00, // ARCOUNT
  ]
  
  match decode_header(data) {
    Ok(header) => {
      inspect(header.id, content="4660") // 0x1234
      inspect(header.qr, content="Query")
      inspect(header.rd, content="true")
      inspect(header.qdcount, content="1")
    }
    Err(e) => {
      inspect(e, content="should not error")
    }
  }
}

test "decode_header too small" {
  let data : FixedArray[Byte] = [0x12, 0x34]
  
  match decode_header(data) {
    Ok(_) => inspect(false, content="true") // Should not succeed
    Err(DnsError::BufferTooSmall(_)) => inspect(true, content="true")
    Err(e) => inspect(e, content="should be BufferTooSmall")
  }
}

test "encode and decode header roundtrip" {
  let original = Header::new(
    12345,
    MessageType::Response,
    OpCode::Query,
    true,
    false,
    true,
    true,
    0,
    ResponseCode::NoError,
    1,
    2,
    0,
    0
  )
  
  let buf = @buffer.HeapByteBuf::new(12)
  encode_header(original, buf as &@buffer.Buffer)
  
  let data : FixedArray[Byte] = FixedArray::make(12, 0)
  buf.read(data, 0, 12) |> ignore
  
  match decode_header(data) {
    Ok(decoded) => {
      inspect(decoded.id, content="12345")
      inspect(decoded.qr, content="Response")
      inspect(decoded.aa, content="true")
      inspect(decoded.rd, content="true")
      inspect(decoded.ra, content="true")
      inspect(decoded.ancount, content="2")
    }
    Err(e) => inspect(e, content="should not error")
  }
}
