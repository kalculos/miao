///| Mock network implementation for testing DNS client
///| This allows us to test DNS functionality without real networking

///| Mock UDP connection for testing
struct MockUdpConnection {
  mut closed : Bool
  response_data : FixedArray[Byte]
  mut bytes_written : Int
}

///| Create a mock UDP connection with a predefined response
fn MockUdpConnection::new(response : FixedArray[Byte]) -> MockUdpConnection {
  { closed: false, response_data: response, bytes_written: 0 }
}

///| Mock implementation of Reader trait
impl @io.Reader for MockUdpConnection with read(self, dst, off, len) {
  if self.closed {
    return 0
  }
  let to_read = @cmp.minimum(len, self.response_data.length())
  for i = 0; i < to_read; i = i + 1 {
    dst[off + i] = self.response_data[i]
  }
  to_read
}

impl @io.Reader for MockUdpConnection with close(self) {
  self.closed = true
}

impl @io.Reader for MockUdpConnection with is_closed(self) {
  self.closed
}

///| Mock implementation of Writer trait
impl @io.Writer for MockUdpConnection with write(self, src, off, len) {
  if self.closed {
    return 0
  }
  self.bytes_written = self.bytes_written + len
  len
}

impl @io.Writer for MockUdpConnection with close(self) {
  self.closed = true
}

impl @io.Writer for MockUdpConnection with is_closed(self) {
  self.closed
}

///| Mock implementation of Channel trait
impl @io.Channel for MockUdpConnection with close(self) {
  self.closed = true
}

impl @io.Channel for MockUdpConnection with is_closed(self) {
  self.closed
}

///| Mock implementation of Connection trait
impl @net.Connection for MockUdpConnection with local_addr(self) {
  // 127.0.0.1 as IPv4 address
  let host = (127 << 24) | (0 << 16) | (0 << 8) | 1
  @net.SockAddr::Inet({ addr: @net.InetAddr::IPv4(host~), port: 12345 })
}

impl @net.Connection for MockUdpConnection with remote_addr(self) {
  // 8.8.8.8 as IPv4 address
  let host = (8 << 24) | (8 << 16) | (8 << 8) | 8
  @net.SockAddr::Inet({ addr: @net.InetAddr::IPv4(host~), port: 53 })
}

impl @net.Connection for MockUdpConnection with flush(self) {
  // No-op for mock
  ()
}

///| Mock network that returns predefined responses
pub struct MockNetwork {
  mut response : Option[FixedArray[Byte]]
}

///| Create a new mock network
pub fn MockNetwork::new() -> MockNetwork {
  { response: None }
}

///| Set the response that the mock network will return
pub fn MockNetwork::set_response(self : MockNetwork, data : FixedArray[Byte]) -> Unit {
  self.response = Some(data)
}

///| Create a mock DNS response for testing
pub fn create_mock_dns_response(id : Int, domain : String) -> FixedArray[Byte] {
  // Create a simple DNS response message
  let buf = @buffer.HeapByteBuf::new(512)
  
  let header = Header::new(
    id,
    MessageType::Response,
    OpCode::Query,
    false, // aa
    false, // tc
    true,  // rd
    true,  // ra
    0,     // z
    ResponseCode::NoError,
    1,     // qdcount
    1,     // ancount
    0,     // nscount
    0      // arcount
  )
  
  encode_header(header, buf as &@buffer.Buffer)
  
  // Encode the question section
  let question = Question::new(domain, RecordType::A, RecordClass::IN)
  
  encode_question(question, buf as &@buffer.Buffer) |> ignore
  
  // Encode a simple answer (this is simplified, real answer encoding would be more complex)
  // For testing purposes, we'll just add some placeholder data
  
  // Convert buffer to byte array
  let result : FixedArray[Byte] = FixedArray::make(buf.readable_bytes(), 0)
  buf.read(result, 0, buf.readable_bytes()) |> ignore
  result
}

///| Implementation of Network trait for mock
impl @net.Network for MockNetwork with dial(self, network, address, options) {
  match self.response {
    Some(data) => {
      let conn = MockUdpConnection::new(data)
      Ok(conn as &@net.Connection)
    }
    None => Err(@net.DeviceFailure(msg="No mock response configured"))
  }
}

impl @net.Network for MockNetwork with bind(self, network, bind_addr, options) {
  Err(@net.DeviceFailure(msg="Mock network does not support bind"))
}
