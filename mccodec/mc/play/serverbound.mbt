///|
/// Confirm Teleportation packet (0x00)
/// Confirms server teleportation
struct ConfirmTeleportationC2S {
  teleport_id : Int // Teleport ID from server
}

///|
impl @mc.Packet for ConfirmTeleportationC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ConfirmTeleportationC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.teleport_id)
}

///|
impl @mc.Packet for ConfirmTeleportationC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { teleport_id: @types.read_varint(buf) }
}

///|
/// Query Block Entity Tag packet (0x01)
/// Queries block entity NBT data
struct QueryBlockEntityTagC2S {
  transaction_id : Int // Transaction ID
  location : @types.Position // Block position
}

///|
impl @mc.Packet for QueryBlockEntityTagC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for QueryBlockEntityTagC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.transaction_id)
  @types.write_position(buf, self.location)
}

///|
impl @mc.Packet for QueryBlockEntityTagC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let transaction_id = @types.read_varint(buf)
  let location = @types.read_position(buf)
  { transaction_id, location }
}

///|
/// Bundle Item Selected packet (0x02)  
/// Selects item from bundle
struct BundleItemSelectedC2S {
  slot_id : Int // Slot containing bundle
  selected_item_index : Int // Index of selected item
}

///|
impl @mc.Packet for BundleItemSelectedC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for BundleItemSelectedC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.slot_id)
  @types.write_varint(buf, self.selected_item_index)
}

///|
impl @mc.Packet for BundleItemSelectedC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let slot_id = @types.read_varint(buf)
  let selected_item_index = @types.read_varint(buf)
  { slot_id, selected_item_index }
}

///|
/// Change Difficulty packet (0x03)
/// Requests difficulty change
struct ChangeDifficultyC2S {
  new_difficulty : Int // Requested difficulty, TODO: enum
}

///|
impl @mc.Packet for ChangeDifficultyC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ChangeDifficultyC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.new_difficulty)
}

///|
impl @mc.Packet for ChangeDifficultyC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { new_difficulty: @types.read_varint(buf) }
}

///|
/// Change Game Mode packet (0x04)
/// Requests game mode change (creative mode only)
struct ChangeGameModeC2S {
  game_mode : Int // Requested game mode, TODO: enum
}

///|
impl @mc.Packet for ChangeGameModeC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ChangeGameModeC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.game_mode)
}

///|
impl @mc.Packet for ChangeGameModeC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { game_mode: @types.read_varint(buf) }
}

///|
/// Acknowledge Message packet (0x05)
/// Acknowledges chat message receipt
struct AcknowledgeMessageC2S {
  message_count : Int // Number of messages acknowledged
}

///|
impl @mc.Packet for AcknowledgeMessageC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for AcknowledgeMessageC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.message_count)
}

///|
impl @mc.Packet for AcknowledgeMessageC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { message_count: @types.read_varint(buf) }
}

///|
/// Chat Command packet (0x06)
/// Sends chat command
struct ChatCommandC2S {
  command : String // Command text (without /)
}

///|
impl @mc.Packet for ChatCommandC2S with clientbound(self) {
  false
}

impl @mc.Packet for ChatCommandC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_string(buf, self.command)
}

impl @mc.Packet for ChatCommandC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let command = @types.read_string(buf)
  { command, }

}

///|
/// Signed Chat Command packet (0x07)
/// Sends signed chat command
/// TODO: (de)serialize
struct SignedChatCommandC2S {
  command : String // Command text
  timestamp : Int64 // Command timestamp
  salt : Int64 // Random salt
  argument_signatures : FixedArray[(String, Array[Byte])] // Argument signatures
  message_count : Int // Message count
  acknowledged : Byte // Acknowledged messages, TODO: BitSet type
  checksum: Byte // Checksum
}

///|
impl @mc.Packet for SignedChatCommandC2S with clientbound(self) {
  false
}

///|
/// Chat Message packet (0x08)
/// Sends chat message
/// TODO: (de)serialize
struct ChatMessageC2S {
  message : String // Chat message content
  timestamp : Int64 // Message timestamp
  salt : Int64 // Random salt
  signature : Array[Byte]? // Message signature
  message_count : Int // Message count
  acknowledged : Array[Byte] // Acknowledged messages, TODO: BitSet type
  checksum: Array[Byte] // Checksum
}

///|
impl @mc.Packet for ChatMessageC2S with clientbound(self) {
  false
}

///|
/// Player Session packet (0x09)
/// Updates player session info
struct PlayerSessionC2S {
  session_uuid : @uuid.UUID // Session UUID
  expires_at : Int64 // Expiration timestamp
  public_key : FixedArray[Byte] // Public key data
  key_signature : FixedArray[Byte] // Key signature
}

///|
impl @mc.Packet for PlayerSessionC2S with clientbound(self) {
  false
}

impl @mc.Packet for PlayerSessionC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_uuid(buf, self.session_uuid)
  buf.write_int64(self.expires_at)
  @types.write_prefix_array(buf, self.public_key, @bytebuf.ByteWriter::write_byte)
  @types.write_prefix_array(buf, self.key_signature, @bytebuf.ByteWriter::write_byte)
}

impl @mc.Packet for PlayerSessionC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let session_uuid = @types.read_uuid(buf)
  let expires_at = buf.read_int64().unwrap()
  let public_key = @types.read_prefix_array(buf, by => by.read_byte().unwrap())
  let key_signature = @types.read_prefix_array(buf, by => by.read_byte().unwrap())
  { session_uuid, expires_at, public_key, key_signature }
}

///|
/// Chunk Batch Received packet (0x0A)
/// Acknowledges chunk batch receipt
struct ChunkBatchReceivedC2S {
  chunks_per_tick : Float // Desired chunks per tick
}

///|
impl @mc.Packet for ChunkBatchReceivedC2S with clientbound(self) {
  false
}

impl @mc.Packet for ChunkBatchReceivedC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  buf.write_float(self.chunks_per_tick)
}

impl @mc.Packet for ChunkBatchReceivedC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { chunks_per_tick: buf.read_float().unwrap() }
}

///|
/// Client Status packet (0x0B)
/// Reports client status
struct ClientStatusC2S {
  action_id : Int // Action (0=respawn, 1=request_stats), TODO: enum
}

///|
impl @mc.Packet for ClientStatusC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ClientStatusC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.action_id)
}

///|
impl @mc.Packet for ClientStatusC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { action_id: @types.read_varint(buf) }
}

///|
/// Client Tick End packet (0x0C)
/// Marks end of client tick
struct ClientTickEndC2S {}

///|
impl @mc.Packet for ClientTickEndC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ClientTickEndC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  // No fields to serialize
}

///|
impl @mc.Packet for ClientTickEndC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  ClientTickEndC2S::{  }
}

///|
/// Client Information (play) packet (0x0D)
/// Updates client settings
struct ClientInformationPlayC2S {
  locale : String // Locale (e.g. "en_us")
  view_distance : Byte // Render distance
  chat_mode : Int // Chat visibility enum(0=enabled, 1=commands_only, 2=hidden)
  chat_colors : Bool // Chat colors enabled
  displayed_skin_parts : Byte // Skin part flags, unsign, TODO: mask
  main_hand : Int // Main hand enum(0=left, 1=right)
  enable_text_filtering : Bool // Text filtering
  allow_server_listings : Bool // Server listings
  particle_status : Int // Particle level enum(0=all, 1=decreased, 2=minimal)
}

///|
impl @mc.Packet for ClientInformationPlayC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ClientInformationPlayC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_string(buf, self.locale)
  buf.write_byte(self.view_distance)
  @types.write_varint(buf, self.chat_mode)
  @types.write_bool(buf, self.chat_colors)
  buf.write_byte(self.displayed_skin_parts)
  @types.write_varint(buf, self.main_hand)
  @types.write_bool(buf, self.enable_text_filtering)
  @types.write_bool(buf, self.allow_server_listings)
  @types.write_varint(buf, self.particle_status)
}

///|
impl @mc.Packet for ClientInformationPlayC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let locale = @types.read_string(buf)
  let view_distance = buf.read_byte().unwrap_or(0)
  let chat_mode = @types.read_varint(buf)
  let chat_colors = @types.read_bool(buf)
  let displayed_skin_parts = buf.read_byte().unwrap_or(0)
  let main_hand = @types.read_varint(buf)
  let enable_text_filtering = @types.read_bool(buf)
  let allow_server_listings = @types.read_bool(buf)
  let particle_status = @types.read_varint(buf)
  {
    locale,
    view_distance,
    chat_mode,
    chat_colors,
    displayed_skin_parts,
    main_hand,
    enable_text_filtering,
    allow_server_listings,
    particle_status,
  }
}

///|
/// Command Suggestions Request packet (0x0E)
/// Requests tab completion
struct CommandSuggestionsRequestC2S {
  transaction_id : Int // Transaction ID
  text : String // Command text to complete
}

///|
impl @mc.Packet for CommandSuggestionsRequestC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for CommandSuggestionsRequestC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.transaction_id)
  @types.write_string(buf, self.text)
}

///|
impl @mc.Packet for CommandSuggestionsRequestC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let transaction_id = @types.read_varint(buf)
  let text = @types.read_string(buf)
  { transaction_id, text }
}

///|
/// Acknowledge Configuration packet (0x0F)
/// Acknowledges configuration completion
struct AcknowledgeConfigurationC2S {}

///|
impl @mc.Packet for AcknowledgeConfigurationC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for AcknowledgeConfigurationC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  // No fields to serialize
}

///|
impl @mc.Packet for AcknowledgeConfigurationC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  AcknowledgeConfigurationC2S::{  }
}

///|
/// Click Container Button packet (0x10)
/// Clicks interface button
struct ClickContainerButtonC2S {
  window_id : Int // Window ID
  button_id : Int // Button ID
}

///|
impl @mc.Packet for ClickContainerButtonC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ClickContainerButtonC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.window_id)
  @types.write_varint(buf, self.button_id)
}

///|
impl @mc.Packet for ClickContainerButtonC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let window_id = @types.read_varint(buf)
  let button_id = @types.read_varint(buf)
  { window_id, button_id }
}

///|
/// Click Container packet (0x11)
/// Clicks container slot
/// TODO: slots type and packet (de)serialize
struct ClickContainerC2S {
  window_id : Int // Window ID
  state_id : Int // State ID
  slot : Int16 // Clicked slot
  button : Byte // Mouse button
  mode : Int // Click mode enum
  changed_slots : FixedArray[(Int16, String)] // Changed slot data
  carried_item : String // Carried item data
}

///|
impl @mc.Packet for ClickContainerC2S with clientbound(self) {
  false
}

///|
/// Close Container packet (0x12)
/// Closes inventory window
struct CloseContainerC2S {
  window_id : Int // Window ID to close
}

///|
impl @mc.Packet for CloseContainerC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for CloseContainerC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.window_id)
}

///|
impl @mc.Packet for CloseContainerC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { window_id: @types.read_varint(buf) }
}

///|
/// Change Container Slot State packet (0x13)
/// Changes container slot state
struct ChangeContainerSlotStateC2S {
  slot_id : Int // Slot ID
  window_id : Int // Window ID
  state : Bool // New state
}

///|
impl @mc.Packet for ChangeContainerSlotStateC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ChangeContainerSlotStateC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.slot_id)
  @types.write_varint(buf, self.window_id)
  @types.write_bool(buf, self.state)
}

///|
impl @mc.Packet for ChangeContainerSlotStateC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let slot_id = @types.read_varint(buf)
  let window_id = @types.read_varint(buf)
  let state = @types.read_bool(buf)
  { slot_id, window_id, state }
}

///|
/// Cookie Response (play) packet (0x14)
/// Response to cookie request
struct CookieResponsePlayC2S {
  key : String // Cookie key, TODO: Identifier type
  payload : FixedArray[Byte]? // Cookie data
}

///|
impl @mc.Packet for CookieResponsePlayC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for CookieResponsePlayC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_string(buf, self.key)
  @types.write_optional(buf, self.payload, (b, p) => @types.write_prefix_array(
    b,
    p,
    @bytebuf.ByteWriter::write_byte,
  ))
}

///|
impl @mc.Packet for CookieResponsePlayC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let key = @types.read_string(buf)
  let payload = @types.read_optional(buf, b => {
    @types.read_prefix_array(b, by => by.read_byte().unwrap_or(0))
  })
  { key, payload }
}

///|
/// Serverbound Plugin Message (play) packet (0x15)
/// Plugin message to server
struct ServerboundPluginMessagePlayC2S {
  channel : String // Plugin channel, TODO: Identifier type
  data : Array[Byte] // Plugin data
}

///|
impl @mc.Packet for ServerboundPluginMessagePlayC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ServerboundPluginMessagePlayC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_string(buf, self.channel)
  buf.write_bytes(Bytes::from_array(self.data))
}

///|
impl @mc.Packet for ServerboundPluginMessagePlayC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let channel = @types.read_string(buf)
  let data = buf.read_bytes(buf.remaining()).unwrap().to_array()
  { channel, data }
}

///|
/// Debug Sample Subscription packet (0x16)
/// Subscribes to debug samples
struct DebugSampleSubscriptionC2S {
  sample_type : Int // Sample type to subscribe to enum(0=tick time)
}

///|
impl @mc.Packet for DebugSampleSubscriptionC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for DebugSampleSubscriptionC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.sample_type)
}

///|
impl @mc.Packet for DebugSampleSubscriptionC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { sample_type: @types.read_varint(buf) }
}

///|
/// Edit Book packet (0x17)
/// Edits book content
struct EditBookC2S {
  slot : Int // Slot containing book
  entries : FixedArray[String] // Book page contents
  title : String? // Book title (if signing)
}

///|
impl @mc.Packet for EditBookC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for EditBookC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.slot)
  @types.write_prefix_array(buf, self.entries, @types.write_string)
  @types.write_optional(buf, self.title, @types.write_string)
}

///|
impl @mc.Packet for EditBookC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let slot = @types.read_varint(buf)
  let entries = @types.read_prefix_array(buf, @types.read_string)
  let title = @types.read_optional(buf, @types.read_string)
  { slot, entries, title }
}

///|
/// Query Entity Tag packet (0x18)
/// Queries entity NBT data
struct QueryEntityTagC2S {
  transaction_id : Int // Transaction ID
  entity_id : Int // Entity ID
}

///|
impl @mc.Packet for QueryEntityTagC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for QueryEntityTagC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.transaction_id)
  @types.write_varint(buf, self.entity_id)
}

///|
impl @mc.Packet for QueryEntityTagC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let transaction_id = @types.read_varint(buf)
  let entity_id = @types.read_varint(buf)
  { transaction_id, entity_id }
}

///|
/// Interact packet (0x19)
/// Interacts with entity
struct InteractC2S {
  entity_id : Int // Target entity ID
  interaction_type : Int // Interaction type enum(0=interact, 1=attack, 2=interact_at)
  target_x : Float? // Target X (for at interaction)
  target_y : Float? // Target Y (for at interaction) 
  target_z : Float? // Target Z (for at interaction)
  hand : Int? // Hand used (for interact/interact_at) enum(0=main, 1=off)
  sneaking : Bool // Whether player is sneaking
}

///|
impl @mc.Packet for InteractC2S with clientbound(self) {
  false
}

impl @mc.Packet for InteractC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.entity_id)
  @types.write_varint(buf, self.interaction_type)
  if self.interaction_type == 2 {
    buf.write_float(self.target_x.unwrap())
    buf.write_float(self.target_y.unwrap())
    buf.write_float(self.target_z.unwrap())
  }
  if self.interaction_type == 0 || self.interaction_type == 2 {
    @types.write_varint(buf, self.hand.unwrap())
  }
  @types.write_bool(buf, self.sneaking)
}

impl @mc.Packet for InteractC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let entity_id = @types.read_varint(buf)
  let interaction_type = @types.read_varint(buf)
  let (target_x, target_y, target_z) = if interaction_type == 2 {
    (
      Some(buf.read_float().unwrap()),
      Some(buf.read_float().unwrap()),
      Some(buf.read_float().unwrap()),
    )
  } else {
    (None, None, None)
  }
  let hand = if interaction_type == 0 || interaction_type == 2 {
    Some(@types.read_varint(buf))
  } else {
    None
  }
  let sneaking = @types.read_bool(buf)
  {
    entity_id,
    interaction_type,
    target_x,
    target_y,
    target_z,
    hand,
    sneaking,
  }
}

///|
/// Jigsaw Generate packet (0x1A)
/// Generates jigsaw structure
struct JigsawGenerateC2S {
  location : @types.Position // Jigsaw block position
  levels : Int // Generation levels
  keep_jigsaws : Bool // Keep jigsaw blocks
}

///|
impl @mc.Packet for JigsawGenerateC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for JigsawGenerateC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_position(buf, self.location)
  @types.write_varint(buf, self.levels)
  @types.write_bool(buf, self.keep_jigsaws)
}

///|
impl @mc.Packet for JigsawGenerateC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let location = @types.read_position(buf);
  let levels = @types.read_varint(buf);
  let keep_jigsaws = @types.read_bool(buf);
  { location, levels, keep_jigsaws }
}

///|
/// Serverbound Keep Alive (play) packet (0x1B)
/// Keep alive response
struct ServerboundKeepAlivePlayC2S {
  keep_alive_id : Int64 // Keep alive ID from server
}

///|
impl @mc.Packet for ServerboundKeepAlivePlayC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ServerboundKeepAlivePlayC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  buf.write_int64(self.keep_alive_id)
}

///|
impl @mc.Packet for ServerboundKeepAlivePlayC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { keep_alive_id: buf.read_int64().unwrap() }
}

///|
/// Lock Difficulty packet (0x1C)
/// Locks difficulty setting
struct LockDifficultyC2S {
  locked : Bool // Whether to lock difficulty
}

///|
impl @mc.Packet for LockDifficultyC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for LockDifficultyC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_bool(buf, self.locked)
}

///|
impl @mc.Packet for LockDifficultyC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { locked: @types.read_bool(buf) }
}

///|
/// Set Player Position packet (0x1D)
/// Updates player position
struct SetPlayerPositionC2S {
  x : Double // X position
  feet_y : Double // Y position at feet
  z : Double // Z position
  on_ground : Byte // Whether on ground, (0x01=on ground, 0x02=pushing against wall)
}

///|
impl @mc.Packet for SetPlayerPositionC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for SetPlayerPositionC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  buf.write_double(self.x)
  buf.write_double(self.feet_y)
  buf.write_double(self.z)
  buf.write_byte(self.on_ground)
}

///|
impl @mc.Packet for SetPlayerPositionC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let x = buf.read_double().unwrap()
  let feet_y = buf.read_double().unwrap()
  let z = buf.read_double().unwrap()
  let on_ground = buf.read_byte().unwrap()
  { x, feet_y, z, on_ground }
}

///|
/// Set Player Position and Rotation packet (0x1E)
/// Updates player position and look direction
struct SetPlayerPositionAndRotationC2S {
  x : Double // X position
  feet_y : Double // Y position at feet
  z : Double // Z position
  yaw : Float // Yaw angle
  pitch : Float // Pitch angle
  on_ground : Byte // Whether on ground, (0x01=on ground, 0x02=pushing against wall)
}

///|
impl @mc.Packet for SetPlayerPositionAndRotationC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for SetPlayerPositionAndRotationC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  buf.write_double(self.x)
  buf.write_double(self.feet_y)
  buf.write_double(self.z)
  buf.write_float(self.yaw)
  buf.write_float(self.pitch)
  buf.write_byte(self.on_ground)
}

///|
impl @mc.Packet for SetPlayerPositionAndRotationC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let x = buf.read_double().unwrap()
  let feet_y = buf.read_double().unwrap()
  let z = buf.read_double().unwrap()
  let yaw = buf.read_float().unwrap()
  let pitch = buf.read_float().unwrap()
  let on_ground = buf.read_byte().unwrap()
  { x, feet_y, z, yaw, pitch, on_ground }
}

///|
/// Set Player Rotation packet (0x1F)
/// Updates player look direction
struct SetPlayerRotationC2S {
  yaw : Float // Yaw angle
  pitch : Float // Pitch angle
  on_ground : Byte // Whether on ground, (0x01=on ground, 0x02=pushing against wall)
}

///|
impl @mc.Packet for SetPlayerRotationC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for SetPlayerRotationC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  buf.write_float(self.yaw)
  buf.write_float(self.pitch)
  buf.write_byte(self.on_ground)
}

///|
impl @mc.Packet for SetPlayerRotationC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let yaw = buf.read_float().unwrap()
  let pitch = buf.read_float().unwrap()
  let on_ground = buf.read_byte().unwrap()
  { yaw, pitch, on_ground }
}

///|
/// Set Player Movement Flags packet (0x20)
/// Sets player movement state flags
struct SetPlayerMovementFlagsC2S {
  on_ground : Byte // Whether on ground, (0x01=on ground, 0x02=pushing against wall)
}

///|
impl @mc.Packet for SetPlayerMovementFlagsC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for SetPlayerMovementFlagsC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  buf.write_byte(self.on_ground)
}

///|
impl @mc.Packet for SetPlayerMovementFlagsC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { on_ground: buf.read_byte().unwrap() }
}

///|
/// Move Vehicle (serverbound) packet (0x21)
/// Moves vehicle entity
struct MoveVehicleC2S {
  x : Double // X position
  y : Double // Y position
  z : Double // Z position
  yaw : Float // Yaw angle
  pitch : Float // Pitch angle
  on_ground: Bool // Whether on ground (This value does not seem to exist)
}

///|
impl @mc.Packet for MoveVehicleC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for MoveVehicleC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  buf.write_double(self.x)
  buf.write_double(self.y)
  buf.write_double(self.z)
  buf.write_float(self.yaw)
  buf.write_float(self.pitch)
  @types.write_bool(buf, self.on_ground)
}

///|
impl @mc.Packet for MoveVehicleC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let x = buf.read_double().unwrap()
  let y = buf.read_double().unwrap()
  let z = buf.read_double().unwrap()
  let yaw = buf.read_float().unwrap()
  let pitch = buf.read_float().unwrap()
  let on_ground = @types.read_bool(buf)
  { x, y, z, yaw, pitch, on_ground }
}

///|
/// Paddle Boat packet (0x22)
/// Controls boat paddles
struct PaddleBoatC2S {
  left_paddle_turning : Bool // Left paddle state
  right_paddle_turning : Bool // Right paddle state
}

///|
impl @mc.Packet for PaddleBoatC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for PaddleBoatC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_bool(buf, self.left_paddle_turning)
  @types.write_bool(buf, self.right_paddle_turning)
}

///|
impl @mc.Packet for PaddleBoatC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let left_paddle_turning = @types.read_bool(buf)
  let right_paddle_turning = @types.read_bool(buf)
  { left_paddle_turning, right_paddle_turning }
}

///|
/// Pick Item From Block packet (0x23)
/// Picks item from block (middle click)
struct PickItemFromBlockC2S {
  location : @types.Position // Block position
  include_nbt : Bool // Include NBT data
}

///|
impl @mc.Packet for PickItemFromBlockC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for PickItemFromBlockC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_position(buf, self.location)
  @types.write_bool(buf, self.include_nbt)
}

///|
impl @mc.Packet for PickItemFromBlockC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let location = @types.read_position(buf)
  let include_nbt = @types.read_bool(buf)
  { location, include_nbt }
}

///|
/// Pick Item From Entity packet (0x24)
/// Picks item from entity (middle click)
struct PickItemFromEntityC2S {
  entity_id : Int // Entity ID
  include_nbt : Bool // Include NBT data
}

///|
impl @mc.Packet for PickItemFromEntityC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for PickItemFromEntityC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.entity_id)
  @types.write_bool(buf, self.include_nbt)
}

///|
impl @mc.Packet for PickItemFromEntityC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let entity_id = @types.read_varint(buf)
  let include_nbt = @types.read_bool(buf)
  { entity_id, include_nbt }
}

///|
/// Ping Request (play) packet (0x25)
/// Sends ping to server
struct PingRequestPlayC2S {
  payload : Int64 // Ping payload
}

///|
impl @mc.Packet for PingRequestPlayC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for PingRequestPlayC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  buf.write_int64(self.payload)
}

///|
impl @mc.Packet for PingRequestPlayC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { payload: buf.read_int64().unwrap() }
}

///|
/// Place Recipe packet (0x26)
/// Places recipe in crafting grid
struct PlaceRecipeC2S {
  window_id : Int // Window ID
  recipe : String // Recipe identifier
  make_all : Bool // Make all possible
}

///|
impl @mc.Packet for PlaceRecipeC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for PlaceRecipeC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  buf.write_int(self.window_id)
  @types.write_string(buf, self.recipe)
  @types.write_bool(buf, self.make_all)
}

///|
impl @mc.Packet for PlaceRecipeC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let window_id = buf.read_int().unwrap()
  let recipe = @types.read_string(buf)
  let make_all = @types.read_bool(buf)
  { window_id, recipe, make_all }
}

///|
/// Player Abilities (serverbound) packet (0x27)
/// Updates player ability flags
struct PlayerAbilitiesC2S {
  flags : Byte // Ability flags (flying bit = 0x02)
}

///|
impl @mc.Packet for PlayerAbilitiesC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for PlayerAbilitiesC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  buf.write_byte(self.flags)
}

///|
impl @mc.Packet for PlayerAbilitiesC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { flags: buf.read_byte().unwrap() }
}

///|
/// Player Action packet (0x28)
/// Player performs block action
struct PlayerActionC2S {
  status : Int // Action status, TODO: enum
  location : @types.Position // Block position
  face : Byte // Block face, TODO: enum
  sequence : Int // Action sequence
}

///|
impl @mc.Packet for PlayerActionC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for PlayerActionC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.status)
  @types.write_position(buf, self.location)
  buf.write_byte(self.face)
  @types.write_varint(buf, self.sequence)
}

///|
impl @mc.Packet for PlayerActionC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let status = @types.read_varint(buf)
  let location = @types.read_position(buf)
  let face = buf.read_byte().unwrap()
  let sequence = @types.read_varint(buf)
  { status, location, face, sequence }
}

///|
/// Player Command packet (0x29)
/// Player entity command
struct PlayerCommandC2S {
  entity_id : Int // Entity ID
  action_id : Int // Action enum(0=crouch, 1=uncrouch, 2=leave_bed, 3=start_sprinting, 4=stop_sprinting, 5=start_horse_jump, 6=stop_horse_jump, 7=open_vehicle_inventory, 8=start_flying_elytra)
  jump_boost : Int // Jump boost (for horse jumping)
}

///|
impl @mc.Packet for PlayerCommandC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for PlayerCommandC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.entity_id)
  @types.write_varint(buf, self.action_id)
  @types.write_varint(buf, self.jump_boost)
}

///|
impl @mc.Packet for PlayerCommandC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let entity_id = @types.read_varint(buf)
  let action_id = @types.read_varint(buf)
  let jump_boost = @types.read_varint(buf)
  { entity_id, action_id, jump_boost }
}

///|
/// Player Input packet (0x2A)
/// Player input controls
struct PlayerInputC2S {
  flags : Byte // Input flags, TODO: bit mask
}

///|
impl @mc.Packet for PlayerInputC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for PlayerInputC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  buf.write_byte(self.flags)
}

///|
impl @mc.Packet for PlayerInputC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let flags = buf.read_byte().unwrap()
  {  flags, }
}

///|
/// Player Loaded packet (0x2B)
/// Indicates player has loaded
struct PlayerLoadedC2S {}

///|
impl @mc.Packet for PlayerLoadedC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for PlayerLoadedC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  // No fields to serialize
}

///|
impl @mc.Packet for PlayerLoadedC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  PlayerLoadedC2S::{  }
}

///|
/// Pong (play) packet (0x2C)
/// Pong response to server ping
struct PongPlayC2S {
  id : Int // Ping ID from server
}

///|
impl @mc.Packet for PongPlayC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for PongPlayC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.id)
}

///|
impl @mc.Packet for PongPlayC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { id: @types.read_varint(buf) }
}

///|
/// Change Recipe Book Settings packet (0x2D)
/// Changes recipe book settings
struct ChangeRecipeBookSettingsC2S {
  book_id : Int // Book type, enum(0=crafting, 1=furnace, 2=blast_furnace, 3=smoker)
  book_open : Bool // Whether book is open
  filter_active : Bool // Whether filter is active
}

///|
impl @mc.Packet for ChangeRecipeBookSettingsC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ChangeRecipeBookSettingsC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.book_id)
  @types.write_bool(buf, self.book_open)
  @types.write_bool(buf, self.filter_active)
}

///|
impl @mc.Packet for ChangeRecipeBookSettingsC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let book_id = @types.read_varint(buf)
  let book_open = @types.read_bool(buf)
  let filter_active = @types.read_bool(buf)
  { book_id, book_open, filter_active }
}

///|
/// Set Seen Recipe packet (0x2E)
/// Marks recipe as seen
struct SetSeenRecipeC2S {
  recipe_id : Int // Recipe identifier
}

///|
impl @mc.Packet for SetSeenRecipeC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for SetSeenRecipeC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.recipe_id)
}

///|
impl @mc.Packet for SetSeenRecipeC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { recipe_id: @types.read_varint(buf) }
}

///|
/// Rename Item packet (0x2F)
/// Renames item in anvil
struct RenameItemC2S {
  item_name : String // New item name
}

///|
impl @mc.Packet for RenameItemC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for RenameItemC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_string(buf, self.item_name)
}

///|
impl @mc.Packet for RenameItemC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { item_name: @types.read_string(buf) }
}

///|
/// Resource Pack Response (play) packet (0x30)
/// Response to resource pack request
struct ResourcePackResponsePlayC2S {
  uuid : @uuid.UUID // Resource pack UUID
  result : Int // Result (0=accepted, 1=declined, 2=failed_download, 3=accepted_download_pack, 4=invalid_url, 5=failed_reload, 6=discarded)
}

///|
impl @mc.Packet for ResourcePackResponsePlayC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ResourcePackResponsePlayC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_uuid(buf, self.uuid)
  @types.write_varint(buf, self.result)
}

///|
impl @mc.Packet for ResourcePackResponsePlayC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let uuid = @types.read_uuid(buf)
  let result = @types.read_varint(buf)
  { uuid, result }
}

///|
/// Seen Advancements packet (0x31)
/// Updates seen advancement tabs
struct SeenAdvancementsC2S {
  action : Int // Action (0=opened_tab, 1=closed_screen)
  tab_id : String? // Tab identifier (for opened_tab), TODO: Identifier type
}

///|
impl @mc.Packet for SeenAdvancementsC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for SeenAdvancementsC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.action)
  @types.write_optional(buf, self.tab_id, @types.write_string)
}

///|
impl @mc.Packet for SeenAdvancementsC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let action = @types.read_varint(buf)
  let tab_id = @types.read_optional(buf, @types.read_string)
  { action, tab_id }
}

///|
/// Select Trade packet (0x32)
/// Selects villager trade
struct SelectTradeC2S {
  selected_slot : Int // Selected trade slot
}

///|
impl @mc.Packet for SelectTradeC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for SelectTradeC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.selected_slot)
}

///|
impl @mc.Packet for SelectTradeC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { selected_slot: @types.read_varint(buf) }
}

///|
/// Set Beacon Effect packet (0x33)
/// Sets beacon effects
struct SetBeaconEffectC2S {
  primary_effect : Int? // Primary effect ID  
  secondary_effect : Int? // Secondary effect ID
}

///|
impl @mc.Packet for SetBeaconEffectC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for SetBeaconEffectC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_optional(buf, self.primary_effect, @types.write_varint)
  @types.write_optional(buf, self.secondary_effect, @types.write_varint)
}

///|
impl @mc.Packet for SetBeaconEffectC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let primary_effect = @types.read_optional(buf, @types.read_varint)
  let secondary_effect = @types.read_optional(buf, @types.read_varint)
  { primary_effect, secondary_effect }
}

///|
/// Set Held Item (serverbound) packet (0x34)
/// Changes held item slot
struct SetHeldItemC2S {
  slot : Int16 // Hotbar slot (0-8)
}

///|
impl @mc.Packet for SetHeldItemC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for SetHeldItemC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  buf.write_int16(self.slot)
}

///|
impl @mc.Packet for SetHeldItemC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { slot: buf.read_int16() |> Option::unwrap }
}

///|
/// Program Command Block packet (0x35)
/// Programs command block
struct ProgramCommandBlockC2S {
  location : @types.Position // Command block position
  command : String // Command text
  mode : Int // Command block mode enum(0=chain, 1=repeat, 2=impulse)
  flags : Byte // Command block flags
}

///|
impl @mc.Packet for ProgramCommandBlockC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ProgramCommandBlockC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_position(buf, self.location)
  @types.write_string(buf, self.command)
  @types.write_varint(buf, self.mode)
  buf.write_byte(self.flags)
}

///|
impl @mc.Packet for ProgramCommandBlockC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let location = @types.read_position(buf)
  let command = @types.read_string(buf)
  let mode = @types.read_varint(buf)
  let flags = buf.read_byte() |> Option::unwrap
  { location, command, mode, flags }
}

///|
/// Program Command Block Minecart packet (0x36)
/// Programs command block minecart
struct ProgramCommandBlockMinecartC2S {
  entity_id : Int // Minecart entity ID
  command : String // Command text
  track_output : Bool // Track output
}

///|
impl @mc.Packet for ProgramCommandBlockMinecartC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ProgramCommandBlockMinecartC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.entity_id)
  @types.write_string(buf, self.command)
  @types.write_bool(buf, self.track_output)
}

///|
impl @mc.Packet for ProgramCommandBlockMinecartC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let entity_id = @types.read_varint(buf)
  let command = @types.read_string(buf)
  let track_output = @types.read_bool(buf)
  { entity_id, command, track_output }
}

///|
/// Set Creative Mode Slot packet (0x37)
/// Changes item in creative inventory slot
/// TODO: Slot type and packet (de)serialize
struct SetCreativeModeSlotC2S {
  slot : Int16 // Slot ID
  clicked_item : String // Item data
}

///|
/// Program Jigsaw Block packet (0x38)
/// Programs jigsaw block
struct ProgramJigsawBlockC2S {
  location : @types.Position // Jigsaw position
  name : String // Jigsaw name, TODO: Identifier type
  target : String // Target name, TODO: Identifier type
  pool : String // Template pool, TODO: Identifier type
  final_state : String // Final state
  joint_type : String // Joint type
  selection_priority : Int // Selection priority
  placement_priority : Int // Placement priority
}

///|
impl @mc.Packet for ProgramJigsawBlockC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ProgramJigsawBlockC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_position(buf, self.location)
  @types.write_string(buf, self.name)
  @types.write_string(buf, self.target)
  @types.write_string(buf, self.pool)
  @types.write_string(buf, self.final_state)
  @types.write_string(buf, self.joint_type)
  @types.write_varint(buf, self.selection_priority)
  @types.write_varint(buf, self.placement_priority)
}

///|
impl @mc.Packet for ProgramJigsawBlockC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let location = @types.read_position(buf)
  let name = @types.read_string(buf)
  let target = @types.read_string(buf)
  let pool = @types.read_string(buf)
  let final_state = @types.read_string(buf)
  let joint_type = @types.read_string(buf)
  let selection_priority = @types.read_varint(buf)
  let placement_priority = @types.read_varint(buf)
  { location, name, target, pool, final_state, joint_type, selection_priority, placement_priority }
}

///|
/// Program Structure Block packet (0x39)
/// Programs structure block
struct ProgramStructureBlockC2S {
  location : @types.Position // Structure block position
  action : Int // Action type, TODO: enum
  mode : Int // Structure mode, TODO: enum
  name : String // Structure name
  offset_x : Byte // X offset
  offset_y : Byte // Y offset
  offset_z : Byte // Z offset
  size_x : Byte // X size
  size_y : Byte // Y size
  size_z : Byte // Z size
  mirror : Int // Mirror type, TODO: enum
  rotation : Int // Rotation type, TODO: enum
  metadata : String // Metadata
  integrity : Float // Structure integrity
  seed : Int64 // Structure seed
  flags : Byte // Structure flags
}

///|
impl @mc.Packet for ProgramStructureBlockC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ProgramStructureBlockC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_position(buf, self.location)
  @types.write_varint(buf, self.action)
  @types.write_varint(buf, self.mode)
  @types.write_string(buf, self.name)
  buf.write_byte(self.offset_x)
  buf.write_byte(self.offset_y)
  buf.write_byte(self.offset_z)
  buf.write_byte(self.size_x)
  buf.write_byte(self.size_y)
  buf.write_byte(self.size_z)
  @types.write_varint(buf, self.mirror)
  @types.write_varint(buf, self.rotation)
  @types.write_string(buf, self.metadata)
  buf.write_float(self.integrity)
  @types.write_varlong(buf, self.seed)
  buf.write_byte(self.flags)
}

///|
impl @mc.Packet for ProgramStructureBlockC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let location = @types.read_position(buf)
  let action = @types.read_varint(buf)
  let mode = @types.read_varint(buf)
  let name = @types.read_string(buf)
  let offset_x = buf.read_byte().unwrap()
  let offset_y = buf.read_byte().unwrap()
  let offset_z = buf.read_byte().unwrap()
  let size_x = buf.read_byte().unwrap()
  let size_y = buf.read_byte().unwrap()
  let size_z = buf.read_byte().unwrap()
  let mirror = @types.read_varint(buf)
  let rotation = @types.read_varint(buf)
  let metadata = @types.read_string(buf)
  let integrity = buf.read_float().unwrap()
  let seed = @types.read_varlong(buf)
  let flags = buf.read_byte().unwrap();
  { location, action, mode, name, offset_x, offset_y, offset_z, size_x, size_y, size_z, mirror, rotation, metadata, integrity, seed, flags }
}

///|
/// Set Test Block packet (0x3A)
/// Sets test block data (for test frameworks)
struct SetTestBlockC2S {
  location : @types.Position // Block position
  block_type : Int // Block type
  block_data : String // Block NBT data
}

///|
impl @mc.Packet for SetTestBlockC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for SetTestBlockC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_position(buf, self.location)
  @types.write_varint(buf, self.block_type)
  @types.write_string(buf, self.block_data)
}

///|
impl @mc.Packet for SetTestBlockC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let location = @types.read_position(buf)
  let block_type = @types.read_varint(buf)
  let block_data = @types.read_string(buf)
  { location, block_type, block_data }
}

///|
/// Update Sign packet (0x3B)
/// Updates sign text
struct UpdateSignC2S {
  location : @types.Position // Sign position
  is_front_text : Bool // Whether editing front text
  line1 : String // Line 1 text
  line2 : String // Line 2 text
  line3 : String // Line 3 text
  line4 : String // Line 4 text
}

///|
impl @mc.Packet for UpdateSignC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for UpdateSignC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_position(buf, self.location)
  @types.write_bool(buf, self.is_front_text)
  @types.write_string(buf, self.line1)
  @types.write_string(buf, self.line2)
  @types.write_string(buf, self.line3)
  @types.write_string(buf, self.line4)
}

///|
impl @mc.Packet for UpdateSignC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let location = @types.read_position(buf)
  let is_front_text = @types.read_bool(buf)
  let line1 = @types.read_string(buf)
  let line2 = @types.read_string(buf)
  let line3 = @types.read_string(buf)
  let line4 = @types.read_string(buf)
  { location, is_front_text, line1, line2, line3, line4 }
}

///|
/// Swing Arm packet (0x3C)
/// Swings player arm
struct SwingArmC2S {
  hand : Int // Hand enum(0=main, 1=off)
}

///|
impl @mc.Packet for SwingArmC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for SwingArmC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.hand)
}

///|
impl @mc.Packet for SwingArmC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { hand: @types.read_varint(buf) }
}

///|
/// Teleport To Entity packet (0x3D)
/// Teleports to entity (spectator mode)
struct TeleportToEntityC2S {
  target_player : @uuid.UUID // Target player UUID
}

///|
impl @mc.Packet for TeleportToEntityC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for TeleportToEntityC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_uuid(buf, self.target_player)
}

///|
impl @mc.Packet for TeleportToEntityC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { target_player: @types.read_uuid(buf) }
}

///|
/// Test Instance Block Action packet (0x3E)
/// Performs test block action
struct TestInstanceBlockActionC2S {
  location : @types.Position // Block position
  action : Int // Test action type enum(0=init, 1=query, 2=set, 3=reset, 4=save, 5=export, 6=run)
  test_id: String // Test identifier, TODO: Identifier type
  size_x : Int // Test size X
  size_y : Int // Test size Y
  size_z : Int // Test size Z
  rotation: Int // Test rotation enum(0=none, 1=clockwise_90, 2=clockwise_180, 3=counterclockwise_90)
  ignore_entities : Bool // Ignore entities flag
  status: Int // enum(0=cleared, 1=running, 2=finished)
  error_message : String? // Error message
}

///|
impl @mc.Packet for TestInstanceBlockActionC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for TestInstanceBlockActionC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  // Position as 3 separate ints
  @types.write_position(buf, self.location)
  @types.write_varint(buf, self.action)
  @types.write_string(buf, self.test_id)
  @types.write_varint(buf, self.size_x)
  @types.write_varint(buf, self.size_y)
  @types.write_varint(buf, self.size_z)
  @types.write_varint(buf, self.rotation)
  @types.write_bool(buf, self.ignore_entities)
  @types.write_varint(buf, self.status)
  @types.write_optional(buf, self.error_message, @types.write_string)
}

///|
impl @mc.Packet for TestInstanceBlockActionC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let location = @types.read_position(buf)
  let action = @types.read_varint(buf)
  let test_id = @types.read_string(buf)
  let size_x = @types.read_varint(buf)
  let size_y = @types.read_varint(buf)
  let size_z = @types.read_varint(buf)
  let rotation = @types.read_varint(buf)
  let ignore_entities = @types.read_bool(buf)
  let status = @types.read_varint(buf)
  let error_message = @types.read_optional(buf, @types.read_string)
  { location, action, test_id, size_x, size_y, size_z, rotation, ignore_entities, status, error_message }
}

///|
/// Use Item On packet (0x3F)
/// Uses item on block
struct UseItemOnC2S {
  hand : Int // Hand used enum(0=main, 1=off)
  location : @types.Position // Block position
  direction : Int // Block face, TODO: enum
  cursor_position_x : Float // Cursor X on block
  cursor_position_y : Float // Cursor Y on block  
  cursor_position_z : Float // Cursor Z on block
  inside_block : Bool // Inside block check
  world_border_hit: Bool // Whether world border was hit
  sequence : Int // Action sequence
}

///|
impl @mc.Packet for UseItemOnC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for UseItemOnC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.hand)
  @types.write_position(buf, self.location)
  @types.write_varint(buf, self.direction)
  buf.write_float(self.cursor_position_x)
  buf.write_float(self.cursor_position_y)
  buf.write_float(self.cursor_position_z)
  @types.write_bool(buf, self.inside_block)
  @types.write_bool(buf, self.world_border_hit)
  @types.write_varint(buf, self.sequence)
}

///|
impl @mc.Packet for UseItemOnC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let hand = @types.read_varint(buf)
  let location = @types.read_position(buf)
  let direction = @types.read_varint(buf)
  let cursor_position_x = buf.read_float() |> Option::unwrap
  let cursor_position_y = buf.read_float() |> Option::unwrap
  let cursor_position_z = buf.read_float() |> Option::unwrap
  let inside_block = @types.read_bool(buf)
  let world_border_hit = @types.read_bool(buf)
  let sequence = @types.read_varint(buf)
  { hand, location, direction, cursor_position_x, cursor_position_y, cursor_position_z, inside_block, world_border_hit, sequence }
}

///|
/// Use Item packet (0x40)
/// Uses held item
struct UseItemC2S {
  hand : Int // Hand used enum(0=main, 1=off)
  sequence : Int // Action sequence
  yaw : Float // Player yaw
  pitch : Float // Player pitch
}

///|
impl @mc.Packet for UseItemC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for UseItemC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.hand)
  @types.write_varint(buf, self.sequence)
  buf.write_float(self.yaw)
  buf.write_float(self.pitch)
}

///|
impl @mc.Packet for UseItemC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let hand = @types.read_varint(buf)
  let sequence = @types.read_varint(buf)
  let yaw = buf.read_float() |> Option::unwrap
  let pitch = buf.read_float() |> Option::unwrap
  { hand, sequence, yaw, pitch }
}
