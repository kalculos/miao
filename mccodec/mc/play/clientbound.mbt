///|
/// Bundle Delimiter packet (0x00)
/// Delimiter for bundle of packets to be processed together
struct BundleDelimiterS2C {}

///|
impl @mc.Packet for BundleDelimiterS2C with clientbound(self) {
  true
}

///|
/// Spawn Entity packet (0x01)
/// Sent when an entity is created
struct SpawnEntityS2C {
  entity_id : Int // Unique entity ID
  entity_uuid : String // UUID of entity
  entity_type : Int // Entity type ID
  x : Double // X position
  y : Double // Y position  
  z : Double // Z position
  pitch : Byte // Pitch angle
  yaw : Byte // Yaw angle
  head_yaw : Byte // Head yaw angle
  data : Int // Entity-specific data
  velocity_x : Int16 // X velocity
  velocity_y : Int16 // Y velocity
  velocity_z : Int16 // Z velocity
}

///|
impl @mc.Packet for SpawnEntityS2C with clientbound(self) {
  true
}

///|
/// Entity Animation packet (0x02)
/// Sent when an entity plays an animation
struct EntityAnimationS2C {
  entity_id : Int // Entity ID
  animation : Byte // Animation type
}

///|
impl @mc.Packet for EntityAnimationS2C with clientbound(self) {
  true
}

///|
/// Award Statistics packet (0x03)
/// Updates client-side statistics
struct AwardStatisticsS2C {
  statistics : Array[(String, String, Int)] // (Category, Statistic, Value) entries
}

///|
impl @mc.Packet for AwardStatisticsS2C with clientbound(self) {
  true
}

///|
/// Acknowledge Block Change packet (0x04)
/// Acknowledges block change prediction
struct AcknowledgeBlockChangeS2C {
  sequence_id : Int // Sequence ID to acknowledge
}

///|
impl @mc.Packet for AcknowledgeBlockChangeS2C with clientbound(self) {
  true
}

///|
/// Set Block Destroy Stage packet (0x05)
/// Shows block breaking animation
struct SetBlockDestroyStageS2C {
  entity_id : Int // Entity breaking the block
  location : (Int, Int, Int) // Block position
  destroy_stage : Byte // Breaking stage (0-9, or -1 to remove)
}

///|
impl @mc.Packet for SetBlockDestroyStageS2C with clientbound(self) {
  true
}

///|
/// Block Entity Data packet (0x06)
/// Updates block entity data
struct BlockEntityDataS2C {
  location : (Int, Int, Int) // Block position
  entity_type : Int // Block entity type
  nbt_data : String // NBT data
}

///|
impl @mc.Packet for BlockEntityDataS2C with clientbound(self) {
  true
}

///|
/// Block Action packet (0x07)
/// Triggers block action animation
struct BlockActionS2C {
  location : (Int, Int, Int) // Block position
  action_id : Byte // Action ID
  action_param : Byte // Action parameter
  block_type : Int // Block type
}

///|
impl @mc.Packet for BlockActionS2C with clientbound(self) {
  true
}

///|
/// Block Update packet (0x08)
/// Updates a single block
struct BlockUpdateS2C {
  location : (Int, Int, Int) // Block position
  block_id : Int // New block state ID
}

///|
impl @mc.Packet for BlockUpdateS2C with clientbound(self) {
  true
}

///|
/// Boss Bar packet (0x09)
/// Manages boss bars
struct BossBarS2C {
  uuid : String // Boss bar UUID
  action : Int // Action type (0=add, 1=remove, 2=update_health, etc)
  title : String? // Boss bar title (for add/update_title)
  health : Float? // Health (0.0-1.0, for add/update_health)
  color : Int? // Color (for add/update_style)
  division : Int? // Division (for add/update_style)
  flags : Byte? // Flags (for add/update_flags)
}

///|
impl @mc.Packet for BossBarS2C with clientbound(self) {
  true
}

///|
/// Change Difficulty packet (0x0A)
/// Changes game difficulty
struct ChangeDifficultyS2C {
  difficulty : Byte // Difficulty level
  difficulty_locked : Bool // Whether difficulty is locked
}

///|
impl @mc.Packet for ChangeDifficultyS2C with clientbound(self) {
  true
}

///|
/// Chunk Batch Finished packet (0x0B)
/// Signals end of chunk batch
struct ChunkBatchFinishedS2C {
  batch_size : Int // Number of chunks in batch
}

///|
impl @mc.Packet for ChunkBatchFinishedS2C with clientbound(self) {
  true
}

///|
/// Chunk Batch Start packet (0x0C)  
/// Signals start of chunk batch
struct ChunkBatchStartS2C {}

///|
impl @mc.Packet for ChunkBatchStartS2C with clientbound(self) {
  true
}

///|
/// Chunk Biomes packet (0x0D)
/// Updates biome data for chunks
struct ChunkBiomesS2C {
  chunk_biomes : Array[(Int, Int, Array[Int])] // (ChunkX, ChunkZ, BiomeData) entries
}

///|
impl @mc.Packet for ChunkBiomesS2C with clientbound(self) {
  true
}

///|
/// Clear Titles packet (0x0E)
/// Clears title display
struct ClearTitlesS2C {
  reset : Bool // Whether to reset title
}

///|
impl @mc.Packet for ClearTitlesS2C with clientbound(self) {
  true
}

///|
/// Command Suggestions Response packet (0x0F)
/// Response to tab completion request
struct CommandSuggestionsResponseS2C {
  id : Int // Request ID
  start : Int // Start of replacement range
  length : Int // Length of replacement range
  matches : Array[(String, String?)] // (Match, Tooltip) entries
}

///|
impl @mc.Packet for CommandSuggestionsResponseS2C with clientbound(self) {
  true
}

///|
/// Commands packet (0x10)
/// Declares available commands
struct CommandsS2C {
  nodes : Array[String] // Command node data (complex structure)
  root_index : Int // Index of root node
}

///|
impl @mc.Packet for CommandsS2C with clientbound(self) {
  true
}

///|
/// Close Container packet (0x11)
/// Closes inventory interface
struct CloseContainerS2C {
  window_id : Byte // Window ID
}

///|
impl @mc.Packet for CloseContainerS2C with clientbound(self) {
  true
}

///|
/// Set Container Content packet (0x12)
/// Sets all slots in container
struct SetContainerContentS2C {
  window_id : Byte // Window ID
  state_id : Int // State ID
  slots : Array[String] // Slot data (ItemStack format)
  carried_item : String // Item being carried
}

///|
impl @mc.Packet for SetContainerContentS2C with clientbound(self) {
  true
}

///|
/// Set Container Property packet (0x13)
/// Updates container property
struct SetContainerPropertyS2C {
  window_id : Byte // Window ID
  property : Int16 // Property ID
  value : Int16 // Property value
}

///|
impl @mc.Packet for SetContainerPropertyS2C with clientbound(self) {
  true
}

///|
/// Set Container Slot packet (0x14)
/// Updates single container slot
struct SetContainerSlotS2C {
  window_id : Byte // Window ID
  state_id : Int // State ID
  slot : Int16 // Slot index
  slot_data : String // Slot item data
}

///|
impl @mc.Packet for SetContainerSlotS2C with clientbound(self) {
  true
}

///|
/// Cookie Request (play) packet (0x15)
/// Requests a stored cookie
struct CookieRequestPlayS2C {
  key : String // Cookie identifier
}

///|
impl @mc.Packet for CookieRequestPlayS2C with clientbound(self) {
  true
}

///|
/// Set Cooldown packet (0x16)
/// Sets item cooldown
struct SetCooldownS2C {
  item_id : Int // Item ID
  cooldown_ticks : Int // Cooldown duration in ticks
}

///|
impl @mc.Packet for SetCooldownS2C with clientbound(self) {
  true
}

///|
/// Chat Suggestions packet (0x17)
/// Provides chat suggestions
struct ChatSuggestionsS2C {
  action : Int // Action (0=add, 1=remove, 2=set)
  entries : Array[String] // Chat suggestion entries
}

///|
impl @mc.Packet for ChatSuggestionsS2C with clientbound(self) {
  true
}

///|
/// Clientbound Plugin Message (play) packet (0x18)
/// Plugin message from server
struct ClientboundPluginMessagePlayS2C {
  channel : String // Plugin channel
  data : Array[Byte] // Plugin data
}

///|
impl @mc.Packet for ClientboundPluginMessagePlayS2C with clientbound(self) {
  true
}

///|
/// Damage Event packet (0x19)
/// Shows damage animation
struct DamageEventS2C {
  entity_id : Int // Damaged entity
  source_type_id : Int // Damage source type
  source_cause_id : Int // Entity causing damage (or 0)
  source_direct_id : Int // Direct damage source (or 0)  
  source_position : (Double, Double, Double)? // Damage source position
}

///|
impl @mc.Packet for DamageEventS2C with clientbound(self) {
  true
}

///|
/// Debug Sample packet (0x1A)
/// Debug performance sample
struct DebugSampleS2C {
  sample : Array[Int64] // Performance sample data
  sample_type : Int // Sample type
}

///|
impl @mc.Packet for DebugSampleS2C with clientbound(self) {
  true
}

///|
/// Delete Message packet (0x1B)
/// Deletes chat message
struct DeleteMessageS2C {
  message_id : Int // Message ID to delete
  signature : Array[Byte] // Message signature
}

///|
impl @mc.Packet for DeleteMessageS2C with clientbound(self) {
  true
}

///|
/// Disconnect (play) packet (0x1C)
/// Disconnects player during play
struct DisconnectPlayS2C {
  reason : String // JSON disconnect reason
}

///|
impl @mc.Packet for DisconnectPlayS2C with clientbound(self) {
  true
}

///|
/// Disguised Chat Message packet (0x1D)
/// Chat message that appears as system message
struct DisguisedChatMessageS2C {
  message : String // Chat message content
  chat_type : Int // Chat type ID
  sender_name : String // Display name of sender
  target_name : String? // Target name (for targeted messages)
}

///|
impl @mc.Packet for DisguisedChatMessageS2C with clientbound(self) {
  true
}

///|
/// Entity Event packet (0x1E)
/// Triggers entity status effect
struct EntityEventS2C {
  entity_id : Int // Entity ID
  entity_status : Byte // Status ID
}

///|
impl @mc.Packet for EntityEventS2C with clientbound(self) {
  true
}

///|
/// Teleport Entity packet (0x1F)
/// Teleports entity to position
struct TeleportEntityS2C {
  entity_id : Int // Entity ID
  x : Double // X position
  y : Double // Y position
  z : Double // Z position
  yaw : Byte // Yaw angle
  pitch : Byte // Pitch angle
  on_ground : Bool // Whether on ground
}

///|
impl @mc.Packet for TeleportEntityS2C with clientbound(self) {
  true
}

///|
/// Explosion packet (0x20)
/// Creates explosion effect
struct ExplosionS2C {
  x : Double // Explosion X
  y : Double // Explosion Y
  z : Double // Explosion Z
  strength : Float // Explosion strength
  records : Array[(Int, Int, Int)] // Affected block positions
  player_motion_x : Float // Player knockback X
  player_motion_y : Float // Player knockback Y
  player_motion_z : Float // Player knockback Z
  block_interaction : Int // Block interaction type
  small_explosion_particle : String // Small particle data
  large_explosion_particle : String // Large particle data
  explosion_sound : String // Explosion sound
}

///|
impl @mc.Packet for ExplosionS2C with clientbound(self) {
  true
}

///|
/// Unload Chunk packet (0x21)
/// Unloads chunk from client
struct UnloadChunkS2C {
  chunk_x : Int // Chunk X coordinate
  chunk_z : Int // Chunk Z coordinate
}

///|
impl @mc.Packet for UnloadChunkS2C with clientbound(self) {
  true
}

///|
/// Game Event packet (0x22)
/// Global game state change
struct GameEventS2C {
  event : Byte // Event type
  value : Float // Event value
}

///|
impl @mc.Packet for GameEventS2C with clientbound(self) {
  true
}

///|
/// Open Horse Screen packet (0x23)
/// Opens horse inventory
struct OpenHorseScreenS2C {
  window_id : Byte // Window ID
  slot_count : Int // Number of slots
  entity_id : Int // Horse entity ID
}

///|
impl @mc.Packet for OpenHorseScreenS2C with clientbound(self) {
  true
}

///|
/// Hurt Animation packet (0x24)
/// Plays hurt animation
struct HurtAnimationS2C {
  entity_id : Int // Entity ID
  yaw : Float // Damage yaw direction
}

///|
impl @mc.Packet for HurtAnimationS2C with clientbound(self) {
  true
}

///|
/// Initialize World Border packet (0x25)
/// Initializes world border
struct InitializeWorldBorderS2C {
  x : Double // Center X
  z : Double // Center Z
  old_diameter : Double // Current diameter
  new_diameter : Double // New diameter
  speed : Int64 // Resize speed
  portal_teleport_boundary : Int // Portal boundary
  warning_blocks : Int // Warning distance
  warning_time : Int // Warning time
}

///|
impl @mc.Packet for InitializeWorldBorderS2C with clientbound(self) {
  true
}

///|
/// Clientbound Keep Alive (play) packet (0x26)
/// Keep connection alive
struct ClientboundKeepAlivePlayS2C {
  keep_alive_id : Int64 // Keep alive ID
}

///|
impl @mc.Packet for ClientboundKeepAlivePlayS2C with clientbound(self) {
  true
}

///|
/// Chunk Data and Update Light packet (0x27)
/// Sends chunk data with lighting
struct ChunkDataAndUpdateLightS2C {
  chunk_x : Int // Chunk X
  chunk_z : Int // Chunk Z
  heightmaps : String // Heightmap NBT
  data : Array[Byte] // Chunk data
  block_entities : Array[String] // Block entity NBT
  sky_light_mask : Int64 // Sky light section mask
  block_light_mask : Int64 // Block light section mask  
  empty_sky_light_mask : Int64 // Empty sky light mask
  empty_block_light_mask : Int64 // Empty block light mask
  sky_light : Array[Array[Byte]] // Sky light arrays
  block_light : Array[Array[Byte]] // Block light arrays
}

///|
impl @mc.Packet for ChunkDataAndUpdateLightS2C with clientbound(self) {
  true
}

///|
/// World Event packet (0x28)
/// Plays world event effect
struct WorldEventS2C {
  event : Int // Event ID
  location : (Int, Int, Int) // Event location
  data : Int // Event data
  disable_relative_volume : Bool // Volume control
}

///|
impl @mc.Packet for WorldEventS2C with clientbound(self) {
  true
}

///|
/// Particle packet (0x29)
/// Spawns particle effect
struct ParticleS2C {
  particle_id : Int // Particle type
  long_distance : Bool // Long distance rendering
  x : Double // X position
  y : Double // Y position
  z : Double // Z position
  offset_x : Float // X offset
  offset_y : Float // Y offset
  offset_z : Float // Z offset
  max_speed : Float // Maximum speed
  particle_count : Int // Number of particles
  data : Array[Byte] // Particle-specific data
}

///|
impl @mc.Packet for ParticleS2C with clientbound(self) {
  true
}

///|
/// Update Light packet (0x2A)
/// Updates lighting information
struct UpdateLightS2C {
  chunk_x : Int // Chunk X
  chunk_z : Int // Chunk Z
  sky_light_mask : Int64 // Sky light mask
  block_light_mask : Int64 // Block light mask
  empty_sky_light_mask : Int64 // Empty sky light mask
  empty_block_light_mask : Int64 // Empty block light mask
  sky_light : Array[Array[Byte]] // Sky light data
  block_light : Array[Array[Byte]] // Block light data
}

///|
impl @mc.Packet for UpdateLightS2C with clientbound(self) {
  true
}

///|
/// Login (play) packet (0x2B)
/// Initial login data for play state
struct LoginPlayS2C {
  entity_id : Int // Player entity ID
  is_hardcore : Bool // Hardcore mode
  dimensions : Array[String] // Available dimensions
  max_players : Int // Max players
  view_distance : Int // View distance
  simulation_distance : Int // Simulation distance
  reduced_debug_info : Bool // Reduced debug info
  enable_respawn_screen : Bool // Enable respawn screen
  do_limited_crafting : Bool // Limited crafting
  dimension_type : String // Dimension type
  dimension_name : String // Dimension name
  hashed_seed : Int64 // World seed hash
  game_mode : Byte // Game mode
  previous_game_mode : Byte // Previous game mode
  is_debug : Bool // Debug world
  is_flat : Bool // Flat world
  death_location : (String, Int, Int, Int)? // Death dimension and position
  portal_cooldown : Int // Portal cooldown
  sea_level : Int // Sea level
  enforces_secure_chat : Bool // Secure chat enforcement
}

///|
impl @mc.Packet for LoginPlayS2C with clientbound(self) {
  true
}

///|
/// Map Data packet (0x2C)
/// Updates map display
struct MapDataS2C {
  map_id : Int // Map ID
  scale : Byte // Map scale
  locked : Bool // Map locked state
  tracking_position : Bool // Track position
  icons : Array[(Int, Byte, Byte, Byte, String?)] // (Type, X, Z, Direction, DisplayName)
  columns : Byte // Map columns
  rows : Byte? // Map rows (if columns > 0)
  x : Byte? // Map X offset (if columns > 0)
  z : Byte? // Map Z offset (if columns > 0)
  data : Array[Byte]? // Map pixel data (if columns > 0)
}

///|
impl @mc.Packet for MapDataS2C with clientbound(self) {
  true
}

///|
/// Merchant Offers packet (0x2D)
/// Updates merchant trading interface
struct MerchantOffersS2C {
  window_id : Int // Window ID
  trades : Array[String] // Trade offer data
  villager_level : Int // Villager level
  experience : Int // Villager experience
  is_regular_villager : Bool // Regular villager flag
  can_restock : Bool // Can restock trades
}

///|
impl @mc.Packet for MerchantOffersS2C with clientbound(self) {
  true
}

///|
/// Update Entity Position packet (0x2E)
/// Updates entity position
struct UpdateEntityPositionS2C {
  entity_id : Int // Entity ID
  delta_x : Int16 // X movement delta
  delta_y : Int16 // Y movement delta
  delta_z : Int16 // Z movement delta
  on_ground : Bool // On ground flag
}

///|
impl @mc.Packet for UpdateEntityPositionS2C with clientbound(self) {
  true
}

///|
/// Update Entity Position and Rotation packet (0x2F)
/// Updates entity position and rotation
struct UpdateEntityPositionAndRotationS2C {
  entity_id : Int // Entity ID
  delta_x : Int16 // X movement delta
  delta_y : Int16 // Y movement delta
  delta_z : Int16 // Z movement delta
  yaw : Byte // Yaw angle
  pitch : Byte // Pitch angle
  on_ground : Bool // On ground flag
}

///|
impl @mc.Packet for UpdateEntityPositionAndRotationS2C with clientbound(self) {
  true
}

///|
/// Move Minecart Along Track packet (0x30)
/// Moves minecart along track
struct MoveMinecartAlongTrackS2C {
  entity_id : Int // Minecart entity ID
  steps : Array[(Double, Double, Double, Float, Float)] // Movement steps
}

///|
impl @mc.Packet for MoveMinecartAlongTrackS2C with clientbound(self) {
  true
}

///|
/// Update Entity Rotation packet (0x31)
/// Updates entity rotation only
struct UpdateEntityRotationS2C {
  entity_id : Int // Entity ID
  yaw : Byte // Yaw angle
  pitch : Byte // Pitch angle
  on_ground : Bool // On ground flag
}

///|
impl @mc.Packet for UpdateEntityRotationS2C with clientbound(self) {
  true
}

///|
/// Move Vehicle (clientbound) packet (0x32)
/// Moves vehicle entity
struct MoveVehicleS2C {
  x : Double // X position
  y : Double // Y position
  z : Double // Z position
  yaw : Float // Yaw angle
  pitch : Float // Pitch angle
}

///|
impl @mc.Packet for MoveVehicleS2C with clientbound(self) {
  true
}

///|
/// Open Book packet (0x33)
/// Opens book interface
struct OpenBookS2C {
  hand : Int // Hand holding book
}

///|
impl @mc.Packet for OpenBookS2C with clientbound(self) {
  true
}

///|
/// Open Screen packet (0x34)
/// Opens GUI screen
struct OpenScreenS2C {
  window_id : Int // Window ID
  window_type : Int // Window type
  window_title : String // Window title
}

///|
impl @mc.Packet for OpenScreenS2C with clientbound(self) {
  true
}

///|
/// Open Sign Editor packet (0x35)
/// Opens sign editing interface
struct OpenSignEditorS2C {
  location : (Int, Int, Int) // Sign position
  is_front_text : Bool // Whether editing front text
}

///|
impl @mc.Packet for OpenSignEditorS2C with clientbound(self) {
  true
}

///|
/// Ping (play) packet (0x36)
/// Server ping packet
struct PingPlayS2C {
  id : Int // Ping ID
}

///|
impl @mc.Packet for PingPlayS2C with clientbound(self) {
  true
}

///|
/// Ping Response (play) packet (0x37)
/// Server ping response
struct PingResponsePlayS2C {
  payload : Int64 // Ping payload
}

///|
impl @mc.Packet for PingResponsePlayS2C with clientbound(self) {
  true
}

///|
/// Place Ghost Recipe packet (0x38)
/// Places ghost recipe items
struct PlaceGhostRecipeS2C {
  window_id : Byte // Window ID
  recipe : String // Recipe identifier
}

///|
impl @mc.Packet for PlaceGhostRecipeS2C with clientbound(self) {
  true
}

///|
/// Player Abilities (clientbound) packet (0x39)
/// Updates player abilities
struct PlayerAbilitiesS2C {
  flags : Byte // Ability flags
  flying_speed : Float // Flying speed
  field_of_view_modifier : Float // FOV modifier
}

///|
impl @mc.Packet for PlayerAbilitiesS2C with clientbound(self) {
  true
}

///|
/// Player Chat Message packet (0x3A)
/// Player chat message
struct PlayerChatMessageS2C {
  sender : String // Sender UUID
  index : Int // Message index
  message_signature : Array[Byte]? // Message signature
  message : String // Message content
  timestamp : Int64 // Message timestamp
  salt : Int64 // Random salt
  previous_messages : Array[(String, Array[Byte]?)] // Previous message signatures
  other_player_message : String? // Other player message
  chat_type : Int // Chat type
  sender_name : String // Sender display name
  target_name : String? // Target display name
}

///|
impl @mc.Packet for PlayerChatMessageS2C with clientbound(self) {
  true
}

///|
/// End Combat packet (0x3B)
/// Ends combat state
struct EndCombatS2C {
  duration : Int // Combat duration in ticks
}

///|
impl @mc.Packet for EndCombatS2C with clientbound(self) {
  true
}

///|
/// Enter Combat packet (0x3C)
/// Enters combat state
struct EnterCombatS2C {}

///|
impl @mc.Packet for EnterCombatS2C with clientbound(self) {
  true
}

///|
/// Combat Death packet (0x3D)
/// Player death in combat
struct CombatDeathS2C {
  player_id : Int // Player entity ID
  message : String // Death message
}

///|
impl @mc.Packet for CombatDeathS2C with clientbound(self) {
  true
}

///|
/// Player Info Remove packet (0x3E)
/// Removes players from player list
struct PlayerInfoRemoveS2C {
  player_uuids : Array[String] // Player UUIDs to remove
}

///|
impl @mc.Packet for PlayerInfoRemoveS2C with clientbound(self) {
  true
}

///|
/// Player Info Update packet (0x3F)
/// Updates player list info
struct PlayerInfoUpdateS2C {
  actions : Byte // Action flags
  players : Array[String] // Player data (complex structure)
}

///|
impl @mc.Packet for PlayerInfoUpdateS2C with clientbound(self) {
  true
}

///|
/// Look At packet (0x40)
/// Makes player look at target
struct LookAtS2C {
  feet_eyes : Int // Anchor point
  target_x : Double // Target X
  target_y : Double // Target Y
  target_z : Double // Target Z
  is_entity : Bool // Whether target is entity
  entity_id : Int? // Entity ID (if is_entity)
  entity_anchor : Int? // Entity anchor point (if is_entity)
}

///|
impl @mc.Packet for LookAtS2C with clientbound(self) {
  true
}

///|
/// Synchronize Player Position packet (0x41)
/// Synchronizes player position
struct SynchronizePlayerPositionS2C {
  x : Double // X position
  y : Double // Y position
  z : Double // Z position
  yaw : Float // Yaw angle
  pitch : Float // Pitch angle
  flags : Byte // Relative position flags
  teleport_id : Int // Teleport ID
}

///|
impl @mc.Packet for SynchronizePlayerPositionS2C with clientbound(self) {
  true
}

///|
/// Player Rotation packet (0x42)
/// Updates player rotation
struct PlayerRotationS2C {
  yaw : Float // Yaw angle
  pitch : Float // Pitch angle
}

///|
impl @mc.Packet for PlayerRotationS2C with clientbound(self) {
  true
}

///|
/// Recipe Book Add packet (0x43)
/// Adds recipes to recipe book
struct RecipeBookAddS2C {
  recipes : Array[String] // Recipe identifiers
  replace : Bool // Replace existing recipes
}

///|
impl @mc.Packet for RecipeBookAddS2C with clientbound(self) {
  true
}

///|
/// Recipe Book Remove packet (0x44)
/// Removes recipes from recipe book
struct RecipeBookRemoveS2C {
  recipes : Array[String] // Recipe identifiers to remove
}

///|
impl @mc.Packet for RecipeBookRemoveS2C with clientbound(self) {
  true
}

///|
/// Recipe Book Settings packet (0x45)
/// Updates recipe book settings
struct RecipeBookSettingsS2C {
  crafting_recipe_book_open : Bool // Crafting book open
  crafting_recipe_book_filter_active : Bool // Crafting filter active
  smelting_recipe_book_open : Bool // Smelting book open
  smelting_recipe_book_filter_active : Bool // Smelting filter active
  blast_furnace_recipe_book_open : Bool // Blast furnace book open
  blast_furnace_recipe_book_filter_active : Bool // Blast furnace filter active
  smoker_recipe_book_open : Bool // Smoker book open
  smoker_recipe_book_filter_active : Bool // Smoker filter active
}

///|
impl @mc.Packet for RecipeBookSettingsS2C with clientbound(self) {
  true
}

///|
/// Remove Entities packet (0x46)
/// Removes entities from world
struct RemoveEntitiesS2C {
  entity_ids : Array[Int] // Entity IDs to remove
}

///|
impl @mc.Packet for RemoveEntitiesS2C with clientbound(self) {
  true
}

///|
/// Remove Entity Effect packet (0x47)
/// Removes effect from entity
struct RemoveEntityEffectS2C {
  entity_id : Int // Entity ID
  effect_id : Int // Effect ID to remove
}

///|
impl @mc.Packet for RemoveEntityEffectS2C with clientbound(self) {
  true
}

///|
/// Reset Score packet (0x48)
/// Resets scoreboard score
struct ResetScoreS2C {
  entity_name : String // Entity name
  objective_name : String? // Objective name (null for all)
}

///|
impl @mc.Packet for ResetScoreS2C with clientbound(self) {
  true
}

///|
/// Remove Resource Pack (play) packet (0x49)
/// Removes resource pack
struct RemoveResourcePackPlayS2C {
  uuid : String? // Pack UUID (null for all)
}

///|
impl @mc.Packet for RemoveResourcePackPlayS2C with clientbound(self) {
  true
}

///|
/// Add Resource Pack (play) packet (0x4A)
/// Adds resource pack
struct AddResourcePackPlayS2C {
  uuid : String // Pack UUID
  url : String // Pack URL
  hash : String // Pack hash
  forced : Bool // Force pack
  prompt_message : String? // Prompt message
}

///|
impl @mc.Packet for AddResourcePackPlayS2C with clientbound(self) {
  true
}

///|
/// Respawn packet (0x4B)
/// Respawns player
struct RespawnS2C {
  dimension_type : String // Dimension type
  dimension_name : String // Dimension name
  hashed_seed : Int64 // World seed hash
  game_mode : Byte // Game mode
  previous_game_mode : Byte // Previous game mode
  is_debug : Bool // Debug world
  is_flat : Bool // Flat world
  copy_metadata : Bool // Copy metadata
  death_location : (String, Int, Int, Int)? // Death location
  portal_cooldown : Int // Portal cooldown
  sea_level : Int // Sea level
}

///|
impl @mc.Packet for RespawnS2C with clientbound(self) {
  true
}

///|
/// Set Head Rotation packet (0x4C)
/// Sets entity head rotation
struct SetHeadRotationS2C {
  entity_id : Int // Entity ID
  head_yaw : Byte // Head yaw angle
}

///|
impl @mc.Packet for SetHeadRotationS2C with clientbound(self) {
  true
}

///|
/// Update Section Blocks packet (0x4D)
/// Updates multiple blocks in section
struct UpdateSectionBlocksS2C {
  chunk_section_position : Int64 // Chunk section position
  blocks : Array[(Int16, Int)] // (Position, BlockState) pairs
}

///|
impl @mc.Packet for UpdateSectionBlocksS2C with clientbound(self) {
  true
}

///|
/// Select Advancements Tab packet (0x4E)
/// Selects advancement tab
struct SelectAdvancementsTabS2C {
  identifier : String? // Tab identifier (null to close)
}

///|
impl @mc.Packet for SelectAdvancementsTabS2C with clientbound(self) {
  true
}

///|
/// Server Data packet (0x4F)
/// Server information data
struct ServerDataS2C {
  motd : String // Server MOTD
  icon : Array[Byte]? // Server icon data
  enforces_secure_chat : Bool // Secure chat enforcement
}

///|
impl @mc.Packet for ServerDataS2C with clientbound(self) {
  true
}

///|
/// Set Action Bar Text packet (0x50)
/// Sets action bar text
struct SetActionBarTextS2C {
  text : String // Action bar text
}

///|
impl @mc.Packet for SetActionBarTextS2C with clientbound(self) {
  true
}

///|
/// Set Border Center packet (0x51)
/// Sets world border center
struct SetBorderCenterS2C {
  x : Double // Center X
  z : Double // Center Z
}

///|
impl @mc.Packet for SetBorderCenterS2C with clientbound(self) {
  true
}

///|
/// Set Border Lerp Size packet (0x52)
/// Animates world border size change
struct SetBorderLerpSizeS2C {
  old_diameter : Double // Current diameter
  new_diameter : Double // New diameter
  speed : Int64 // Resize speed in milliseconds
}

///|
impl @mc.Packet for SetBorderLerpSizeS2C with clientbound(self) {
  true
}

///|
/// Set Border Size packet (0x53)
/// Sets world border size instantly
struct SetBorderSizeS2C {
  diameter : Double // Border diameter
}

///|
impl @mc.Packet for SetBorderSizeS2C with clientbound(self) {
  true
}

///|
/// Set Border Warning Delay packet (0x54)
/// Sets border warning delay
struct SetBorderWarningDelayS2C {
  warning_time : Int // Warning time in seconds
}

///|
impl @mc.Packet for SetBorderWarningDelayS2C with clientbound(self) {
  true
}

///|
/// Set Border Warning Distance packet (0x55)
/// Sets border warning distance
struct SetBorderWarningDistanceS2C {
  warning_blocks : Int // Warning distance in blocks
}

///|
impl @mc.Packet for SetBorderWarningDistanceS2C with clientbound(self) {
  true
}

///|
/// Set Camera packet (0x56)
/// Sets camera target entity
struct SetCameraS2C {
  camera_id : Int // Camera entity ID
}

///|
impl @mc.Packet for SetCameraS2C with clientbound(self) {
  true
}

///|
/// Set Center Chunk packet (0x57)
/// Sets center chunk for loading
struct SetCenterChunkS2C {
  chunk_x : Int // Center chunk X
  chunk_z : Int // Center chunk Z
}

///|
impl @mc.Packet for SetCenterChunkS2C with clientbound(self) {
  true
}

///|
/// Set Render Distance packet (0x58)
/// Sets client render distance
struct SetRenderDistanceS2C {
  view_distance : Int // View distance in chunks
}

///|
impl @mc.Packet for SetRenderDistanceS2C with clientbound(self) {
  true
}

///|
/// Set Cursor Item packet (0x59)
/// Sets cursor item
struct SetCursorItemS2C {
  slot_data : String // Item data
}

///|
impl @mc.Packet for SetCursorItemS2C with clientbound(self) {
  true
}

///|
/// Set Default Spawn Position packet (0x5A)
/// Sets world spawn position
struct SetDefaultSpawnPositionS2C {
  location : (Int, Int, Int) // Spawn position
  angle : Float // Spawn angle
}

///|
impl @mc.Packet for SetDefaultSpawnPositionS2C with clientbound(self) {
  true
}

///|
/// Display Objective packet (0x5B)
/// Displays scoreboard objective
struct DisplayObjectiveS2C {
  position : Byte // Display position
  score_name : String // Objective name
}

///|
impl @mc.Packet for DisplayObjectiveS2C with clientbound(self) {
  true
}

///|
/// Set Entity Metadata packet (0x5C)
/// Sets entity metadata
struct SetEntityMetadataS2C {
  entity_id : Int // Entity ID
  metadata : Array[String] // Metadata entries
}

///|
impl @mc.Packet for SetEntityMetadataS2C with clientbound(self) {
  true
}

///|
/// Link Entities packet (0x5D)
/// Links entities together
struct LinkEntitiesS2C {
  attached_entity_id : Int // Attached entity
  holding_entity_id : Int // Holding entity
}

///|
impl @mc.Packet for LinkEntitiesS2C with clientbound(self) {
  true
}

///|
/// Set Entity Velocity packet (0x5E)
/// Sets entity velocity
struct SetEntityVelocityS2C {
  entity_id : Int // Entity ID
  velocity_x : Int16 // X velocity
  velocity_y : Int16 // Y velocity
  velocity_z : Int16 // Z velocity
}

///|
impl @mc.Packet for SetEntityVelocityS2C with clientbound(self) {
  true
}

///|
/// Set Equipment packet (0x5F)
/// Sets entity equipment
struct SetEquipmentS2C {
  entity_id : Int // Entity ID
  equipment : Array[(Byte, String)] // (Slot, Item) pairs
}

///|
impl @mc.Packet for SetEquipmentS2C with clientbound(self) {
  true
}

///|
/// Set Experience packet (0x60)
/// Sets player experience
struct SetExperienceS2C {
  experience_bar : Float // Experience bar progress
  level : Int // Experience level
  total_experience : Int // Total experience
}

///|
impl @mc.Packet for SetExperienceS2C with clientbound(self) {
  true
}

///|
/// Set Health packet (0x61)
/// Sets player health
struct SetHealthS2C {
  health : Float // Player health
  food : Int // Food level
  food_saturation : Float // Food saturation
}

///|
impl @mc.Packet for SetHealthS2C with clientbound(self) {
  true
}

///|
/// Set Held Item (clientbound) packet (0x62)
/// Sets held item slot
struct SetHeldItemS2C {
  slot : Byte // Selected slot
}

///|
impl @mc.Packet for SetHeldItemS2C with clientbound(self) {
  true
}

///|
/// Update Objectives packet (0x63)
/// Updates scoreboard objectives
struct UpdateObjectivesS2C {
  objective_name : String // Objective name
  mode : Byte // Mode (0=create, 1=remove, 2=update)
  objective_display_name : String? // Display name (for create/update)
  render_type : Int? // Render type (for create/update)
  number_format : String? // Number format (for create/update)
}

///|
impl @mc.Packet for UpdateObjectivesS2C with clientbound(self) {
  true
}

///|
/// Set Passengers packet (0x64)
/// Sets entity passengers
struct SetPassengersS2C {
  entity_id : Int // Vehicle entity ID
  passenger_ids : Array[Int] // Passenger entity IDs
}

///|
impl @mc.Packet for SetPassengersS2C with clientbound(self) {
  true
}

///|
/// Set Player Inventory Slot packet (0x65)
/// Sets player inventory slot
struct SetPlayerInventorySlotS2C {
  slot : Int16 // Slot index
  slot_data : String // Item data
}

///|
impl @mc.Packet for SetPlayerInventorySlotS2C with clientbound(self) {
  true
}

///|
/// Update Teams packet (0x66)
/// Updates scoreboard teams
struct UpdateTeamsS2C {
  team_name : String // Team name
  mode : Byte // Mode (0=create, 1=remove, 2=update_info, 3=add_entities, 4=remove_entities)
  display_name : String? // Team display name
  prefix : String? // Team prefix
  suffix : String? // Team suffix
  friendly_flags : Byte? // Friendly fire flags
  name_tag_visibility : String? // Name tag visibility
  collision_rule : String? // Collision rule
  color : Int? // Team color
  entities : Array[String]? // Entity names
}

///|
impl @mc.Packet for UpdateTeamsS2C with clientbound(self) {
  true
}

///|
/// Update Score packet (0x67)
/// Updates scoreboard score
struct UpdateScoreS2C {
  entity_name : String // Entity name
  objective_name : String // Objective name
  value : Int // Score value
  display_name : String? // Display name
  number_format : String? // Number format
}

///|
impl @mc.Packet for UpdateScoreS2C with clientbound(self) {
  true
}

///|
/// Set Simulation Distance packet (0x68)
/// Sets simulation distance
struct SetSimulationDistanceS2C {
  simulation_distance : Int // Simulation distance
}

///|
impl @mc.Packet for SetSimulationDistanceS2C with clientbound(self) {
  true
}

///|
/// Set Subtitle Text packet (0x69)
/// Sets subtitle text
struct SetSubtitleTextS2C {
  subtitle_text : String // Subtitle text
}

///|
impl @mc.Packet for SetSubtitleTextS2C with clientbound(self) {
  true
}

///|
/// Update Time packet (0x6A)
/// Updates world time
struct UpdateTimeS2C {
  world_age : Int64 // World age in ticks
  time_of_day : Int64 // Time of day in ticks
}

///|
impl @mc.Packet for UpdateTimeS2C with clientbound(self) {
  true
}

///|
/// Set Title Text packet (0x6B)
/// Sets title text
struct SetTitleTextS2C {
  title_text : String // Title text
}

///|
impl @mc.Packet for SetTitleTextS2C with clientbound(self) {
  true
}

///|
/// Set Title Animation Times packet (0x6C)
/// Sets title animation timing
struct SetTitleAnimationTimesS2C {
  fade_in : Int // Fade in time in ticks
  stay : Int // Stay time in ticks
  fade_out : Int // Fade out time in ticks
}

///|
impl @mc.Packet for SetTitleAnimationTimesS2C with clientbound(self) {
  true
}

///|
/// Entity Sound Effect packet (0x6D)
/// Plays sound from entity
struct EntitySoundEffectS2C {
  sound_id : Int // Sound ID
  sound_category : Int // Sound category
  entity_id : Int // Entity ID
  volume : Float // Sound volume
  pitch : Float // Sound pitch
  seed : Int64 // Random seed
}

///|
impl @mc.Packet for EntitySoundEffectS2C with clientbound(self) {
  true
}

///|
/// Sound Effect packet (0x6E)
/// Plays positioned sound
struct SoundEffectS2C {
  sound_id : Int // Sound ID
  sound_category : Int // Sound category
  x : Int // X position (*8)
  y : Int // Y position (*8)
  z : Int // Z position (*8)
  volume : Float // Sound volume
  pitch : Float // Sound pitch
  seed : Int64 // Random seed
}

///|
impl @mc.Packet for SoundEffectS2C with clientbound(self) {
  true
}

///|
/// Start Configuration packet (0x6F)
/// Starts configuration phase
struct StartConfigurationS2C {}

///|
impl @mc.Packet for StartConfigurationS2C with clientbound(self) {
  true
}

///|
/// Stop Sound packet (0x70)
/// Stops playing sound
struct StopSoundS2C {
  flags : Byte // Stop flags
  source : Int? // Sound source (if flag set)
  sound : String? // Sound identifier (if flag set)
}

///|
impl @mc.Packet for StopSoundS2C with clientbound(self) {
  true
}

///|
/// Store Cookie (play) packet (0x71)
/// Stores cookie on client
struct StoreCookiePlayS2C {
  key : String // Cookie key
  payload : Array[Byte] // Cookie payload
}

///|
impl @mc.Packet for StoreCookiePlayS2C with clientbound(self) {
  true
}

///|
/// System Chat Message packet (0x72)
/// System chat message
struct SystemChatMessageS2C {
  content : String // Message content
  overlay : Bool // Display as overlay
}

///|
impl @mc.Packet for SystemChatMessageS2C with clientbound(self) {
  true
}

///|
/// Set Tab List Header And Footer packet (0x73)
/// Sets tab list header/footer
struct SetTabListHeaderAndFooterS2C {
  header : String // Tab list header
  footer : String // Tab list footer
}

///|
impl @mc.Packet for SetTabListHeaderAndFooterS2C with clientbound(self) {
  true
}

///|
/// Tag Query Response packet (0x74)
/// Response to tag query
struct TagQueryResponseS2C {
  transaction_id : Int // Transaction ID
  nbt : String // NBT data
}

///|
impl @mc.Packet for TagQueryResponseS2C with clientbound(self) {
  true
}

///|
/// Pickup Item packet (0x75)
/// Item pickup animation
struct PickupItemS2C {
  collected_entity_id : Int // Collected item entity ID
  collector_entity_id : Int // Collector entity ID
  pickup_item_count : Int // Number of items picked up
}

///|
impl @mc.Packet for PickupItemS2C with clientbound(self) {
  true
}

///|
/// Synchronize Vehicle Position packet (0x76)
/// Synchronizes vehicle position
struct SynchronizeVehiclePositionS2C {
  x : Double // X position
  y : Double // Y position
  z : Double // Z position
  yaw : Float // Yaw angle
  pitch : Float // Pitch angle
}

///|
impl @mc.Packet for SynchronizeVehiclePositionS2C with clientbound(self) {
  true
}

///|
/// Test Instance Block Status packet (0x77)
/// Test block status update
struct TestInstanceBlockStatusS2C {
  location : (Int, Int, Int) // Block position
  block_state : Int // Block state ID
  block_entity_data : String? // Block entity NBT
}

///|
impl @mc.Packet for TestInstanceBlockStatusS2C with clientbound(self) {
  true
}

///|
/// Set Ticking State packet (0x78)
/// Sets world ticking state
struct SetTickingStateS2C {
  tick_rate : Float // Tick rate
  is_frozen : Bool // Whether world is frozen
}

///|
impl @mc.Packet for SetTickingStateS2C with clientbound(self) {
  true
}

///|
/// Step Tick packet (0x79)
/// Steps world tick
struct StepTickS2C {
  tick_steps : Int // Number of ticks to step
}

///|
impl @mc.Packet for StepTickS2C with clientbound(self) {
  true
}

///|
/// Transfer (play) packet (0x7A)
/// Transfers to another server
struct TransferPlayS2C {
  host : String // Target server host
  port : Int // Target server port
}

///|
impl @mc.Packet for TransferPlayS2C with clientbound(self) {
  true
}

///|
/// Update Advancements packet (0x7B)
/// Updates advancement data
struct UpdateAdvancementsS2C {
  reset : Bool // Reset advancements
  advancement_mapping : Array[(String, String)] // (ID, Data) pairs
  identifiers : Array[String] // Identifiers to remove
  progress_mapping : Array[(String, String)] // (ID, Progress) pairs
}

///|
impl @mc.Packet for UpdateAdvancementsS2C with clientbound(self) {
  true
}

///|
/// Update Attributes packet (0x7C)
/// Updates entity attributes
struct UpdateAttributesS2C {
  entity_id : Int // Entity ID
  attributes : Array[(String, Double, Array[(String, String, Double, Int)])] // Attribute data
}

///|
impl @mc.Packet for UpdateAttributesS2C with clientbound(self) {
  true
}

///|
/// Entity Effect packet (0x7D)
/// Applies entity effect
struct EntityEffectS2C {
  entity_id : Int // Entity ID
  effect_id : Int // Effect ID
  amplifier : Int // Effect amplifier
  duration : Int // Effect duration
  flags : Byte // Effect flags
  factor_data : String? // Factor calculation data
}

///|
impl @mc.Packet for EntityEffectS2C with clientbound(self) {
  true
}

///|
/// Update Recipes packet (0x7E)
/// Updates recipe data
struct UpdateRecipesS2C {
  property_sets : Array[(String, Array[Int])] // Property sets
  stonecutter_recipes : Array[(String, String)] // Stonecutter recipes
}

///|
impl @mc.Packet for UpdateRecipesS2C with clientbound(self) {
  true
}

///|
/// Update Tags (play) packet (0x7F)
/// Updates tag data
struct UpdateTagsPlayS2C {
  tags : Array[(String, Array[(String, Array[Int])])] // Registry tags
}

///|
impl @mc.Packet for UpdateTagsPlayS2C with clientbound(self) {
  true
}

///|
/// Projectile Power packet (0x80)
/// Sets projectile power data
struct ProjectilePowerS2C {
  entity_id : Int // Projectile entity ID
  power_x : Double // Power X
  power_y : Double // Power Y
  power_z : Double // Power Z
}

///|
impl @mc.Packet for ProjectilePowerS2C with clientbound(self) {
  true
}

///|
/// Custom Report Details packet (0x81)
/// Custom crash report details
struct CustomReportDetailsS2C {
  details : Array[(String, String)] // (Title, Description) pairs
}

///|
impl @mc.Packet for CustomReportDetailsS2C with clientbound(self) {
  true
}

///|
/// Server Links packet (0x82)
/// Server links for pause menu
struct ServerLinksS2C {
  links : Array[(String, String)] // (Label, URL) pairs
}

///|
impl @mc.Packet for ServerLinksS2C with clientbound(self) {
  true
}

///|
/// Waypoint packet (0x83)
/// Sets waypoint data
struct WaypointS2C {
  location : (Int, Int, Int) // Waypoint position
  name : String // Waypoint name
  color : Int // Waypoint color
}

///|
impl @mc.Packet for WaypointS2C with clientbound(self) {
  true
}

///|
/// Clear Dialog (play) packet (0x84)
/// Clears dialog screen
struct ClearDialogPlayS2C {}

///|
impl @mc.Packet for ClearDialogPlayS2C with clientbound(self) {
  true
}

///|
/// Show Dialog (play) packet (0x85)
/// Shows dialog screen
struct ShowDialogPlayS2C {
  dialog : String // Dialog NBT data
}

///|
impl @mc.Packet for ShowDialogPlayS2C with clientbound(self) {
  true
}
