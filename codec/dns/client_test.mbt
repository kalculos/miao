///| Tests for DNS client functionality

async test "DnsClient creation" {
  let client = DnsClient::new("8.8.8.8:53")
  inspect(client.server, content="8.8.8.8:53")
}

async test "DnsClient with custom timeout" {
  let timeout = @time.Duration::of_millis(10000L)
  let client = DnsClient::new("8.8.8.8:53", timeout=timeout)
  inspect(client.server, content="8.8.8.8:53")
}

async test "create mock DNS response" {
  let response = create_mock_dns_response(12345, "example.com")
  inspect(response.length() > 12, content="true") // At least header size
}

async test "MockNetwork creation" {
  let mock = MockNetwork::new()
  inspect(mock.response is None, content="true")
}

async test "encode simple DNS query message" {
  let header = Header::new(
    100,
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
  
  let question = Question::new("google.com", RecordType::A, RecordClass::IN)
  
  let msg = Message::new(header, [question], [], [], [])
  
  match encode_message(msg) {
    Ok(buf) => {
      inspect(buf.readable_bytes() > 0, content="true")
      
      // Decode it back
      let data : FixedArray[Byte] = FixedArray::make(buf.readable_bytes(), 0)
      buf.read(data, 0, buf.readable_bytes()) |> ignore
      
      match decode_message(data) {
        Ok(decoded) => {
          inspect(decoded.header.id, content="100")
          inspect(decoded.questions.length(), content="1")
          inspect(decoded.questions[0].qname, content="google.com")
        }
        Err(e) => inspect(e, content="should not error")
      }
    }
    Err(e) => inspect(e, content="should not error")
  }
}

async test "DNS error types" {
  let err1 : DnsError = DnsError::InvalidFormat("test")
  let err2 : DnsError = DnsError::BufferTooSmall("test")
  let err3 : DnsError = DnsError::InvalidName("test")
  
  inspect(err1 == DnsError::InvalidFormat("test"), content="true")
  inspect(err2 == DnsError::BufferTooSmall("test"), content="true")
  inspect(err3 == DnsError::InvalidName("test"), content="true")
  inspect(err1 == err2, content="false")
}
