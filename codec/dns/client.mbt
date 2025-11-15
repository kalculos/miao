///| DNS Client for making DNS queries
pub struct DnsClient {
  server : String // DNS server address (e.g., "8.8.8.8:53")
  timeout : @time.Duration
}

///| Create a new DNS client
pub fn DnsClient::new(server : String, timeout? : @time.Duration = @time.Duration::of_millis(5000L)) -> DnsClient {
  { server, timeout }
}

///| DNS Query Result
pub(all) enum DnsResult {
  Success(Message)
  Error(DnsError)
  NetworkError(@net.NetworkError)
  Timeout
} derive(Show)

///| Perform a DNS query
pub async fn DnsClient::query(
  self : DnsClient,
  domain : String,
  record_type : RecordType
) -> DnsResult {
  // Create a DNS query message
  let id = (@time.Instant::now().to_epoch_milli() % 65536L).to_int() // Simple random ID
  
  let header = Header::new(
    id,
    MessageType::Query,
    OpCode::Query,
    false, // aa
    false, // tc
    true,  // rd (recursion desired)
    false, // ra
    0,     // z
    ResponseCode::NoError,
    1,     // qdcount
    0,     // ancount
    0,     // nscount
    0      // arcount
  )
  
  let question = Question::new(domain, record_type, RecordClass::IN)
  
  let msg = Message::new(header, [question], [], [], [])
  
  // Encode the message
  let encoded = match encode_message(msg) {
    Ok(buf) => buf
    Err(e) => return Error(e)
  }
  
  // Send the query via UDP
  match @net.dial_udp(self.server) {
    Ok(conn) => {
      // Prepare query data
      let query_data : FixedArray[Byte] = FixedArray::make(encoded.readable_bytes(), 0)
      encoded.read(query_data, 0, encoded.readable_bytes()) |> ignore
      
      // Send the DNS query
      let bytes_written = (@io.Writer::write(conn, query_data, 0, query_data.length()) : Int)
      if bytes_written != query_data.length() {
        (@io.Channel::close(conn) : Unit)
        return Error(InvalidFormat("Failed to send complete query"))
      }
      
      // Flush to ensure data is sent
      (@net.Connection::flush(conn) : Unit)
      
      // Read the response (DNS responses are typically small, use 512 bytes buffer)
      let response_data : FixedArray[Byte] = FixedArray::make(512, 0)
      let bytes_read = (@io.Reader::read(conn, response_data, 0, 512) : Int)
      
      // Close the connection
      (@io.Channel::close(conn) : Unit)
      
      if bytes_read <= 0 {
        return Error(InvalidFormat("No response received"))
      }
      
      // Decode the response
      let response_slice : FixedArray[Byte] = FixedArray::make(bytes_read, 0)
      for i = 0; i < bytes_read; i = i + 1 {
        response_slice[i] = response_data[i]
      }
      
      match decode_message(response_slice) {
        Ok(response_msg) => Success(response_msg)
        Err(e) => Error(e)
      }
    }
    Err(e) => NetworkError(e)
  }
}

///| Query for A record (IPv4 address)
pub async fn DnsClient::query_a(self : DnsClient, domain : String) -> DnsResult {
  self.query(domain, RecordType::A)
}

///| Query for AAAA record (IPv6 address)
pub async fn DnsClient::query_aaaa(self : DnsClient, domain : String) -> DnsResult {
  self.query(domain, RecordType::AAAA)
}

///| Query for MX record (mail exchange)
pub async fn DnsClient::query_mx(self : DnsClient, domain : String) -> DnsResult {
  self.query(domain, RecordType::MX)
}

///| Query for TXT record
pub async fn DnsClient::query_txt(self : DnsClient, domain : String) -> DnsResult {
  self.query(domain, RecordType::TXT)
}
