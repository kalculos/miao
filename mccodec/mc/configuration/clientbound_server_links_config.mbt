///|
enum ServerLinkType {
  BugReport
  CommunityGuidelines
  Support
  Status
  Feedback
  Community
  Website
  Forums
  News
  Announcements
}

///|
pub fn ServerLinkType::from_int(val : Int) -> ServerLinkType? {
  match val {
    0 => Some(ServerLinkType::BugReport)
    1 => Some(ServerLinkType::CommunityGuidelines)
    2 => Some(ServerLinkType::Support)
    3 => Some(ServerLinkType::Status)
    4 => Some(ServerLinkType::Feedback)
    5 => Some(ServerLinkType::Community)
    6 => Some(ServerLinkType::Website)
    7 => Some(ServerLinkType::Forums)
    8 => Some(ServerLinkType::News)
    9 => Some(ServerLinkType::Announcements)
    _ => None
  }
}

///|
pub fn ServerLinkType::to_int(self : ServerLinkType) -> Int {
  match self {
    ServerLinkType::BugReport => 0
    ServerLinkType::CommunityGuidelines => 1
    ServerLinkType::Support => 2
    ServerLinkType::Status => 3
    ServerLinkType::Feedback => 4
    ServerLinkType::Community => 5
    ServerLinkType::Website => 6
    ServerLinkType::Forums => 7
    ServerLinkType::News => 8
    ServerLinkType::Announcements => 9
  }
}

///|
struct ServerLink {
  knownType : ServerLinkType?
  unknownType : String? // TODO: Text Component type
  url : String
}

///|
/// Server Links (configuration) packet (0x10)
/// Contains server links for pause menu
struct ServerLinksConfigS2C {
  links : FixedArray[ServerLink]
}

///|
impl @mc.Packet for ServerLinksConfigS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for ServerLinksConfigS2C with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_prefix_array(buf, self.links, (b, link) => {
    if link.knownType is Some(knownType) {
      @types.write_bool(b, true)
      @types.write_varint(b, knownType.to_int())
    } else if link.unknownType is Some(unknownType) {
      @types.write_bool(b, false)
      @types.write_string(b, unknownType)
    }
    @types.write_string(b, link.url)
  })
}

///|
impl @mc.Packet for ServerLinksConfigS2C with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let links = @types.read_prefix_array(buf, b => {
    let mut knownType : ServerLinkType? = None
    let mut unknownType : String? = None
    if @types.read_bool(buf) {
      knownType = ServerLinkType::from_int(@types.read_varint(buf))
    } else {
      unknownType = Some(@types.read_string(buf))
    }
    let url = @types.read_string(b)
    ServerLink::{ knownType, unknownType, url }
  })
  { links, }
}
