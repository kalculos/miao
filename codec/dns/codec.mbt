///| DNS Encoding/Decoding Error
pub(all) enum DnsError {
  InvalidFormat(String)
  BufferTooSmall(String)
  InvalidName(String)
  InvalidHeader(String)
} derive(Show, Eq)

///| Encode a domain name in DNS wire format
///| Domain names are encoded as labels separated by length bytes
///| For example: "www.example.com" becomes:
///| 3 w w w 7 e x a m p l e 3 c o m 0
fn encode_domain_name(name : String, buf : &@buffer.Buffer) -> Result[Unit, DnsError] {
  if name.length() == 0 {
    // Root domain
    buf.write_byte(0) |> ignore
    return Ok(())
  }
  
  let parts = name.split(".")
  for part in parts {
    let len = part.length()
    if len == 0 || len > 63 {
      return Err(InvalidName("Label length must be 1-63 characters"))
    }
    // Write label length
    buf.write_byte(len.to_byte()) |> ignore
    // Write label bytes
    for i = 0; i < len; i = i + 1 {
      buf.write_byte(part[i].to_byte()) |> ignore
    }
  }
  // Write terminating null byte
  buf.write_byte(0) |> ignore
  Ok(())
}

///| Decode a domain name from DNS wire format
///| Returns (decoded_name, bytes_consumed)
fn decode_domain_name(data : FixedArray[Byte], offset : Int) -> Result[(String, Int), DnsError] {
  let mut pos = offset
  let mut name = ""
  let mut first = true
  let start_pos = offset
  
  while pos < data.length() {
    let len = data[pos].to_int()
    pos = pos + 1
    
    if len == 0 {
      // End of name
      break
    }
    
    // Check for compression pointer (RFC 1035 section 4.1.4)
    if len >= 192 {
      // This is a compression pointer
      // For now, we don't support compression in basic implementation
      return Err(InvalidFormat("Name compression not supported in this implementation"))
    }
    
    if len > 63 {
      return Err(InvalidName("Invalid label length"))
    }
    
    if pos + len > data.length() {
      return Err(BufferTooSmall("Not enough data for label"))
    }
    
    if not(first) {
      name = name + "."
    }
    first = false
    
    // Read label characters
    for i = 0; i < len; i = i + 1 {
      name = name + Char::from_int(data[pos].to_int()).to_string()
      pos = pos + 1
    }
  }
  
  Ok((name, pos - start_pos))
}

///| Encode DNS message header to buffer
pub fn encode_header(header : Header, buf : &@buffer.Buffer) -> Unit {
  // ID (16 bits)
  buf.write_byte((header.id.lsr(8)).land(0xFF).to_byte()) |> ignore
  buf.write_byte(header.id.land(0xFF).to_byte()) |> ignore
  
  // Flags (16 bits)
  let mut flags = 0
  
  // QR bit (bit 15)
  let qr_bit = match header.qr {
    MessageType::Query => 0
    MessageType::Response => 1
  }
  flags = flags.lor(qr_bit.lsl(15))
  
  // Opcode (bits 14-11)
  flags = flags.lor(header.opcode.to_int().lsl(11))
  
  // AA bit (bit 10)
  if header.aa {
    flags = flags.lor((1).lsl(10))
  }
  
  // TC bit (bit 9)
  if header.tc {
    flags = flags.lor((1).lsl(9))
  }
  
  // RD bit (bit 8)
  if header.rd {
    flags = flags.lor((1).lsl(8))
  }
  
  // RA bit (bit 7)
  if header.ra {
    flags = flags.lor((1).lsl(7))
  }
  
  // Z (bits 6-4, reserved, must be 0)
  // Already 0
  
  // RCODE (bits 3-0)
  flags = flags.lor(header.rcode.to_int())
  
  buf.write_byte(flags.lsr(8).land(0xFF).to_byte()) |> ignore
  buf.write_byte(flags.land(0xFF).to_byte()) |> ignore
  
  // Question count (16 bits)
  buf.write_byte(header.qdcount.lsr(8).land(0xFF).to_byte()) |> ignore
  buf.write_byte(header.qdcount.land(0xFF).to_byte()) |> ignore
  
  // Answer count (16 bits)
  buf.write_byte(header.ancount.lsr(8).land(0xFF).to_byte()) |> ignore
  buf.write_byte(header.ancount.land(0xFF).to_byte()) |> ignore
  
  // Authority count (16 bits)
  buf.write_byte(header.nscount.lsr(8).land(0xFF).to_byte()) |> ignore
  buf.write_byte(header.nscount.land(0xFF).to_byte()) |> ignore
  
  // Additional count (16 bits)
  buf.write_byte(header.arcount.lsr(8).land(0xFF).to_byte()) |> ignore
  buf.write_byte(header.arcount.land(0xFF).to_byte()) |> ignore
}

///| Decode DNS message header from buffer
pub fn decode_header(data : FixedArray[Byte]) -> Result[Header, DnsError] {
  if data.length() < 12 {
    return Err(BufferTooSmall("Header must be at least 12 bytes"))
  }
  
  // ID
  let id = data[0].to_int().lsl(8).lor(data[1].to_int())
  
  // Flags
  let flags = data[2].to_int().lsl(8).lor(data[3].to_int())
  
  let qr = if flags.land(0x8000) != 0 { MessageType::Response } else { MessageType::Query }
  let opcode = OpCode::from_int(flags.lsr(11).land(0xF))
  let aa = flags.land(0x0400) != 0
  let tc = flags.land(0x0200) != 0
  let rd = flags.land(0x0100) != 0
  let ra = flags.land(0x0080) != 0
  let z = flags.lsr(4).land(0x7)
  let rcode = ResponseCode::from_int(flags.land(0xF))
  
  // Counts
  let qdcount = data[4].to_int().lsl(8).lor(data[5].to_int())
  let ancount = data[6].to_int().lsl(8).lor(data[7].to_int())
  let nscount = data[8].to_int().lsl(8).lor(data[9].to_int())
  let arcount = data[10].to_int().lsl(8).lor(data[11].to_int())
  
  Ok(Header::new(id, qr, opcode, aa, tc, rd, ra, z, rcode, qdcount, ancount, nscount, arcount))
}

///| Encode a DNS question to buffer
pub fn encode_question(question : Question, buf : &@buffer.Buffer) -> Result[Unit, DnsError] {
  // Encode domain name
  match encode_domain_name(question.qname, buf) {
    Ok(_) => ()
    Err(e) => return Err(e)
  }
  
  // Query type (16 bits)
  let qtype = question.qtype.to_int()
  buf.write_byte(qtype.lsr(8).land(0xFF).to_byte()) |> ignore
  buf.write_byte(qtype.land(0xFF).to_byte()) |> ignore
  
  // Query class (16 bits)
  let qclass = question.qclass.to_int()
  buf.write_byte(qclass.lsr(8).land(0xFF).to_byte()) |> ignore
  buf.write_byte(qclass.land(0xFF).to_byte()) |> ignore
  
  Ok(())
}

///| Decode a DNS question from buffer
///| Returns (question, bytes_consumed)
pub fn decode_question(data : FixedArray[Byte], offset : Int) -> Result[(Question, Int), DnsError] {
  let name_result = decode_domain_name(data, offset)
  match name_result {
    Err(e) => return Err(e)
    Ok((qname, name_len)) => {
      let mut pos = offset + name_len
      
      if pos + 4 > data.length() {
        return Err(BufferTooSmall("Not enough data for question"))
      }
      
      // Query type
      let qtype = RecordType::from_int(
        data[pos].to_int().lsl(8).lor(data[pos + 1].to_int())
      )
      pos = pos + 2
      
      // Query class
      let qclass = RecordClass::from_int(
        data[pos].to_int().lsl(8).lor(data[pos + 1].to_int())
      )
      pos = pos + 2
      
      Ok((Question::new(qname, qtype, qclass), pos - offset))
    }
  }
}

///| Encode a complete DNS message to buffer
pub fn encode_message(msg : Message) -> Result[&@buffer.Buffer, DnsError] {
  let buf = @buffer.HeapByteBuf::new(512) // Standard DNS packet size
  
  // Encode header
  encode_header(msg.header, buf as &@buffer.Buffer)
  
  // Encode questions
  for question in msg.questions {
    match encode_question(question, buf as &@buffer.Buffer) {
      Ok(_) => ()
      Err(e) => return Err(e)
    }
  }
  
  // For now, we only support encoding questions
  // Answers, authority, and additional sections would be encoded similarly
  
  Ok(buf as &@buffer.Buffer)
}

///| Decode a complete DNS message from buffer
pub fn decode_message(buf : &@buffer.Buffer) -> Result[Message, DnsError] {
  // Read all data from buffer into a FixedArray for parsing
  let data_len = buf.readable_bytes()
  if data_len < 12 {
    return Err(BufferTooSmall("Message must be at least 12 bytes"))
  }
  
  let data : FixedArray[Byte] = FixedArray::make(data_len, 0)
  buf.read(data, 0, data_len) |> ignore
  
  // Decode header
  let header_result = decode_header(data)
  match header_result {
    Err(e) => return Err(e)
    Ok(header) => {
      let mut offset = 12 // Header is 12 bytes
      
      // Decode questions
      let questions = Array::new()
      for i = 0; i < header.qdcount; i = i + 1 {
        match decode_question(data, offset) {
          Err(e) => return Err(e)
          Ok((question, consumed)) => {
            questions.push(question)
            offset = offset + consumed
          }
        }
      }
      
      // For now, we'll skip parsing answers, authority, and additional records
      // A full implementation would decode these as well
      
      Ok(Message::new(header, questions, [], [], []))
    }
  }
}
