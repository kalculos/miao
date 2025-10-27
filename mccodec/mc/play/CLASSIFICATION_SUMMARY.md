# Minecraft Protocol Packet Classification

## Classification Results

**Total Packets**: 199 (134 clientbound, 65 serverbound) organized into **8 functional categories**.

| Category | Clientbound | Serverbound | Total | Description |
|----------|-------------|-------------|-------|-------------|
| **World** | 36 | 11 | **47** | Global state, UI, sounds, administrative |
| **Player** | 19 | 15 | **34** | Player management, abilities, combat |
| **Entity** | 25 | 3 | **28** | Entity lifecycle, movement, interactions |
| **Level** | 19 | 6 | **25** | Chunks, blocks, world structure |
| **Common** | 12 | 11 | **23** | Core networking, keep-alive, plugins |
| **Inventory** | 12 | 11 | **23** | Items, containers, inventory management |
| **Chat** | 5 | 5 | **10** | Messages, commands, communication |
| **Recipe** | 6 | 3 | **9** | Crafting, trading, merchant systems |

## Classification Criteria

Packets were categorized based on:
1. **Primary Function** - What does the packet do?
2. **Data Domain** - Which game system does it affect?
3. **User Interaction** - How do players interact with this feature?
4. **System Boundaries** - Which subsystem owns the data?

## Directory Structure

```
mccodec/mc/play/
├── moon.pkg.json               # Root package configuration
├── chat/                       # Chat & messaging (10 packets)
├── common/                     # Core networking (23 packets)
├── entity/                     # Entity management (28 packets)
├── inventory/                  # Items & containers (23 packets)
├── level/                      # World structure (25 packets)
├── player/                     # Player state (34 packets)
├── recipe/                     # Crafting system (9 packets)
└── world/                      # Global state & UI (47 packets)
```
