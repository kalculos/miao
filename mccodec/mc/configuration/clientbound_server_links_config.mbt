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
  (match val {
    0 => ServerLinkType::BugReport
    1 => ServerLinkType::CommunityGuidelines
    2 => ServerLinkType::Support
    3 => ServerLinkType::Status
    4 => ServerLinkType::Feedback
    5 => ServerLinkType::Community
    6 => ServerLinkType::Website
    7 => ServerLinkType::Forums
    8 => ServerLinkType::News
    9 => ServerLinkType::Announcements
    _ => return None
  })
  |> Some
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
pub(all) struct ServerLinksConfigS2C {
  links : FixedArray[ServerLink]
}

///|
pub impl @mc.Packet for ServerLinksConfigS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for ServerLinksConfigS2C with serialize(
  self,
  buf : &@buffer.Buffer,
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
pub impl @mc.Packet for ServerLinksConfigS2C with deserialize(
  buf : &@buffer.Buffer,
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
