///| Tests for DNS message types and conversions

test "RecordType conversion" {
  inspect(RecordType::A.to_int(), content="1")
  inspect(RecordType::from_int(1), content="A")
  inspect(RecordType::AAAA.to_int(), content="28")
  inspect(RecordType::from_int(28), content="AAAA")
}

test "RecordClass conversion" {
  inspect(RecordClass::IN.to_int(), content="1")
  inspect(RecordClass::from_int(1), content="IN")
}

test "OpCode conversion" {
  inspect(OpCode::Query.to_int(), content="0")
  inspect(OpCode::from_int(0), content="Query")
}

test "ResponseCode conversion" {
  inspect(ResponseCode::NoError.to_int(), content="0")
  inspect(ResponseCode::from_int(0), content="NoError")
  inspect(ResponseCode::NameError.to_int(), content="3")
  inspect(ResponseCode::from_int(3), content="NameError")
}

test "MessageType equality" {
  inspect(MessageType::Query == MessageType::Query, content="true")
  inspect(MessageType::Query == MessageType::Response, content="false")
}

test "Header creation with constructor" {
  let header = Header::new(
    12345,
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
  inspect(header.id, content="12345")
  inspect(header.rd, content="true")
  inspect(header.qdcount, content="1")
}

test "Question creation with constructor" {
  let question = Question::new("example.com", RecordType::A, RecordClass::IN)
  inspect(question.qname, content="example.com")
  inspect(question.qtype, content="A")
}
