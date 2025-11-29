///| DNS Message Types
pub(all) enum MessageType {
  Query
  Response
} derive(Eq, Show)

///| DNS Operation Codes
pub(all) enum OpCode {
  Query // Standard query
  IQuery // Inverse query (obsolete)
  Status // Server status request
  Reserved(Int) // Reserved for future use
} derive(Eq, Show)

///| DNS Response Codes
pub(all) enum ResponseCode {
  NoError // No error condition
  FormatError // Format error - server unable to interpret query
  ServerFailure // Server failure
  NameError // Name does not exist (NXDOMAIN)
  NotImplemented // Query type not implemented
  Refused // Server refused to answer
  Reserved(Int) // Reserved for future use
} derive(Eq, Show)

///| DNS Resource Record Types
pub(all) enum RecordType {
  A // IPv4 address
  NS // Name server
  CNAME // Canonical name
  SOA // Start of authority
  PTR // Pointer record
  MX // Mail exchange
  TXT // Text record
  AAAA // IPv6 address
  Unknown(Int) // Unknown or unsupported type
} derive(Eq, Show)

///| DNS Classes
pub(all) enum RecordClass {
  IN // Internet
  CS // CSNET (obsolete)
  CH // CHAOS
  HS // Hesiod
  Unknown(Int) // Unknown class
} derive(Eq, Show)

///| DNS Message Header (12 bytes)
pub struct Header {
  pub id : Int // Transaction ID
  pub qr : MessageType // Query/Response flag
  pub opcode : OpCode // Operation code
  pub aa : Bool // Authoritative answer
  pub tc : Bool // Truncation flag
  pub rd : Bool // Recursion desired
  pub ra : Bool // Recursion available
  pub z : Int // Reserved (must be zero)
  pub rcode : ResponseCode // Response code
  pub qdcount : Int // Number of questions
  pub ancount : Int // Number of answers
  pub nscount : Int // Number of authority records
  pub arcount : Int // Number of additional records
} derive(Show)

///| Create a new Header
pub fn Header::new(id : Int, qr : MessageType, opcode : OpCode, aa : Bool, tc : Bool, rd : Bool, ra : Bool, z : Int, rcode : ResponseCode, qdcount : Int, ancount : Int, nscount : Int, arcount : Int) -> Header {
  { id, qr, opcode, aa, tc, rd, ra, z, rcode, qdcount, ancount, nscount, arcount }
}

///| DNS Question Section
pub struct Question {
  pub qname : String // Domain name to query
  pub qtype : RecordType // Query type
  pub qclass : RecordClass // Query class
} derive(Show)

///| Create a new Question
pub fn Question::new(qname : String, qtype : RecordType, qclass : RecordClass) -> Question {
  { qname, qtype, qclass }
}

///| DNS Resource Record
pub struct ResourceRecord {
  pub name : String // Domain name
  pub rtype : RecordType // Record type
  pub rclass : RecordClass // Record class
  pub ttl : Int // Time to live
  pub rdlength : Int // Resource data length
  pub rdata : FixedArray[Byte] // Resource data
} derive(Show)

///| Create a new ResourceRecord
pub fn ResourceRecord::new(name : String, rtype : RecordType, rclass : RecordClass, ttl : Int, rdlength : Int, rdata : FixedArray[Byte]) -> ResourceRecord {
  { name, rtype, rclass, ttl, rdlength, rdata }
}

///| DNS Message
pub struct Message {
  pub header : Header
  pub questions : Array[Question]
  pub answers : Array[ResourceRecord]
  pub authority : Array[ResourceRecord]
  pub additional : Array[ResourceRecord]
} derive(Show)

///| Create a new Message
pub fn Message::new(header : Header, questions : Array[Question], answers : Array[ResourceRecord], authority : Array[ResourceRecord], additional : Array[ResourceRecord]) -> Message {
  { header, questions, answers, authority, additional }
}

///| Convert RecordType to wire format integer
pub fn RecordType::to_int(self : RecordType) -> Int {
  match self {
    A => 1
    NS => 2
    CNAME => 5
    SOA => 6
    PTR => 12
    MX => 15
    TXT => 16
    AAAA => 28
    Unknown(n) => n
  }
}

///| Convert integer to RecordType
pub fn RecordType::from_int(n : Int) -> RecordType {
  match n {
    1 => A
    2 => NS
    5 => CNAME
    6 => SOA
    12 => PTR
    15 => MX
    16 => TXT
    28 => AAAA
    _ => Unknown(n)
  }
}

///| Convert RecordClass to wire format integer
pub fn RecordClass::to_int(self : RecordClass) -> Int {
  match self {
    IN => 1
    CS => 2
    CH => 3
    HS => 4
    Unknown(n) => n
  }
}

///| Convert integer to RecordClass
pub fn RecordClass::from_int(n : Int) -> RecordClass {
  match n {
    1 => IN
    2 => CS
    3 => CH
    4 => HS
    _ => Unknown(n)
  }
}

///| Convert OpCode to wire format integer
pub fn OpCode::to_int(self : OpCode) -> Int {
  match self {
    Query => 0
    IQuery => 1
    Status => 2
    Reserved(n) => n
  }
}

///| Convert integer to OpCode
pub fn OpCode::from_int(n : Int) -> OpCode {
  match n {
    0 => Query
    1 => IQuery
    2 => Status
    _ => Reserved(n)
  }
}

///| Convert ResponseCode to wire format integer
pub fn ResponseCode::to_int(self : ResponseCode) -> Int {
  match self {
    NoError => 0
    FormatError => 1
    ServerFailure => 2
    NameError => 3
    NotImplemented => 4
    Refused => 5
    Reserved(n) => n
  }
}

///| Convert integer to ResponseCode
pub fn ResponseCode::from_int(n : Int) -> ResponseCode {
  match n {
    0 => NoError
    1 => FormatError
    2 => ServerFailure
    3 => NameError
    4 => NotImplemented
    5 => Refused
    _ => Reserved(n)
  }
}
