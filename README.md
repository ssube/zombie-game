# Zombie Game

A Quake 3 style zombie shooter set in a small town, built with Godot and an Entity Component System architecture. Open source code with paid assets.

## Features

### Combat

- Melee and ranged weapon system with weapon switching
- Critical hit areas and headshots with damage multipliers
- Armor system with damage reduction
- Path-based weapon recoil
- Damage areas and environmental hazards
- Explosion system with line-of-sight checks
- Melee weapons only deal damage during swing animation
- Combat relationships tracking (fired, killed)
- Experience/score system with transfer on kill
- Stamina system with drain on movement, attacks, jumping, and sprinting

### Weapons

- Baseball bat with swing-activated damage areas
- Shotgun with projectile impacts
- Weapon equip and use sounds
- Weapon effects system (muzzle flash, etc.)
- Melee weapon durability system with surface-based damage
- Weapon broken/empty sound effects
- Ammo system with pickup, reload, and consumption
- Ammo counter displays current, max, and spare ammunition
- Weapon holster action
- Partial ammo pickup (leaves remainder if inventory full)

### Enemies

- Zombie AI using finite state machines
- Vision cone detection system with performance optimization
- Navigation mesh pathfinding
- Wander and chase behaviors
- Zombie variants (flashlight zombie worker, slime that splits on death)
- Attention system with stimulus input queue and decay
- Horde behavior (zombies follow other aggressive zombies)
- Perception system for hearing and seeing events
- Enemy weapons don't damage other enemies
- Optimized vision checks (only active when player nearby)

### Environment

- Interactive doors with auto-close and proximity triggers
- Multiple door types: standard rotating, breakable, automatic sliding
- Fire and burning mechanics (spreads, resets timer)
- Water areas with movement speed modifiers
- Water extinguishes fires
- Flammable entities and environmental fire damage
- Bullet and impact decals based on surface type
- Surface type system integrated with Trenchbroom/func_godot
- Breakable glass with particle effects and sounds
- Interactive buttons (push/toggle with auto-reset)
- Pressure plates for triggering actions
- Dripping water prefabs
- Locks and keys separated from door system (can lock anything)

### Screen Effects

- Hit indicator
- Low health vignette
- Underwater distortion with scrolling shader
- Fire and acid/poison effects
- Support for multiple simultaneous effects with fade in/out
- Armor and healing effects
- Effect strength curves for customizable fade behavior
- Screen effect expiration system with automatic fade-out
- Support for overlapping effects with same type
- Temporary and persistent effect durations

### NPCs and Dialogue

- Friendly survivor characters
- Dialogue system with trees and random clips
- Character rotation tweening for conversations
- Dialogue commands (look at player, look at marker)
- Dialogue integrated with game HUD (hides HUD during conversations)
- Dialogue captures input without pausing game
- Faction system for identifying enemies, friendlies, and players

### Levels and Maps

- FuncGodot integration for Quake-style brush mapping
- Level switching with named player spawn points
- Unique entity IDs per level
- Entity grouping by room for organization
- Occlusion culling support
- Campaign resource system with level metadata
- Loading screen images and level-specific hints
- CLI arguments for selecting debug level and spawn point
- Fallback spawn point support

### Inventory and Items

- Inventory system linked via ECS relationships
- Medkits with health subtypes (food, medical, magic)
- Keys and locked doors/containers
- Armor pickups
- Item shimmer effect for interactive objects
- Use items from inventory menu
- Inventory items hidden and physics disabled when carried
- Inventory items follow player in 3D space
- Weapon marker system for equipped items
- Item pickup, equip, and use sounds

### Objectives

- Objective tree system
- Counter objectives (e.g., "blast 20 zombies")
- Completion triggers: on interaction, damage, or death
- Active objective display in HUD
- Objective status persistence

### Controls

- Mouse look with capture management
- Controller support
- Flashlight toggle
- Weapon holster and reload actions
- Inventory and objectives menu shortcuts
- Item pickup without immediate consumption

### Menus and UI

- Main menu, pause menu, settings menu
- Loading screen with gameplay hints that fade in/out
- Game over screen
- Player health bar synced on start
- Current weapon and ammo display (hidden for melee, shows durability for melee)
- Current objective in HUD
- Debug menu with framerate display
- Cheats menu with no-clip mode (god mode and no aggro planned)
- Inventory menu with double-click to use
- Objectives menu with active objective switching
- Exit confirmation with natural duration format since last save
- New save name prompts and overwrite confirmation
- Saves sorted by date
- Shader toggle in pause menu

### Save System

- Level state persistence
- Options save/load
- Objective status saving
- Save files stored in user directory

### Audio

- Weapon fire and impact sounds
- Weapon reload sounds
- Weapon broken/empty sounds
- Explosion sounds
- Footstep sounds based on surface material
- Footstep interval adjusts with movement speed (sprinting/sneaking)
- Split footstep sounds for players and zombies (zombies louder)
- Impact sounds based on surface type
- Item pickup, equip, and use sounds
- Door open and close sounds
- Glass breaking sounds
- Subtitle system for accessibility
- Noise component for subtitle generation
- Multiple sound support in audio actions (random/all play modes)

### Physics

- Collision layers: world, props, items, player, enemies
- Character body support (static and rigid bodies)
- Surface type detection for effects and sounds
- Support for entities with multiple physics bodies
- Gimbal node for maintaining rotation with configurable resistance

### Actions and Triggers

- Unified action system for interactive entities
- Trigger areas with enter/exit/interval events
- Trigger timers with auto-start and one-shot modes
- Action conditions (faction checks, etc.)
- Remote action nodes for connecting action trees
- Extra actions component for level-specific behaviors
- Cooldown component and system for rate limiting interactions
- Action nodes for behavior state machines (FSM integration)
- Spawn action with configurable spread per axis
- Door and lock actions (separated for flexibility)
- Experience action for adding/removing points
- Audio action with multiple sound support
- Raycast area for line-of-sight based triggers

## Addons

- **Debug Menu** - Framerate and frame time display
  - https://github.com/godot-extended-libraries/godot-debug-menu
- **Dialogue Manager** - Dialogue randomization and conversation trees
  - https://github.com/nathanhoad/godot_dialogue_manager
- **Func Godot** - Quake-style map import from Trenchbroom
  - https://github.com/func-godot/func_godot_plugin
- **GECS** - Entity Componeknt System framework
  - https://github.com/csprance/gecs/
- **Godot Object Serializer** - JSON support for save games
  - https://github.com/Cretezy/godot-object-serializer
- **Quake-Style Light Animations for Godot** - Light animation support
  - https://github.com/ioannis-koukourakis/quake-style-light-animations-for-the-godot-engine
- **VisionCone3D** - Vision cone checks for AI detection
  - https://github.com/Tattomoosa/VisionCone3D
- **Zombie Tools** - Custom editor tools (collision mesh fixing, component sorting, lock/objective validation)
  - https://github.com/ssube/zombie-game/tree/main/addons/zombie_tools

## Assets

### Structure

TODO: document asset structure

### Asset Packs

TODO: list paid asset packs

## Singletons

- **ECS** - Entity Component System world management
- **DecalManager** - Bullet holes and impact decals by surface type
- **DialogueManager** - Dialogue playback and balloon instantiation
- **ObjectiveManager** - Objective tree tracking and completion
- **SaveManager** - Save game file management
- **CheatsManager** - Debug cheats (no-clip mode implemented)

## Architecture Notes

### Entity Component System

The game uses GECS for entity management. Entities can receive components from three sources (applied in order, later
sources override earlier):

1. Standard editor components (component resources)
2. Extra editor components (level-specific additions)
3. Parent node with CopyComponents script

This allows prefabs to be extended per-level without breaking prefab inheritance.

### Screen Overlay Effects

Screen effects are implemented as ECS relationships with strength and duration. Effects can be toggled with infinite
duration or set to fade out over time. Specialized Area3D nodes add and remove effects when entities enter or exit.

### Impact Effects

The projectile system handles impact effects based on surface type detection. Each surface type can define custom impact
sounds and visual effects:

- **Asphalt** - Concrete dust and impact sounds
- **Concrete** - Similar to asphalt with concrete-specific effects
- **Grass** - Dirt scatter and soft impact sounds
- **Metal** - Sparks and metallic ping sounds
- **Stone** - Stone chips and hard impact sounds
- **Wood** - Splinters and thud sounds
- **Zombie** - Green goo and squelch sounds

Impact decals are aligned with the surface normal of the hit location. Decals use the Sprite3D class to support Godot's
compatibility renderer.

### Surface Type Detection

Collision helpers provide surface type detection used by both the impact effects and footstep systems. Surface types can
be assigned via collision shape metadata.

Surface metadata is integrated into the func_godot import pipeline, automatically detecting surface types based on texture
keywords with the ability to override using material metadata and entity properties.

The global DecalManager maintains a lookup table mapping surface types to their corresponding decal scenes and impact
sounds.

### Sound Management

Footsteps are handled by an ECS system, using the same surface type detection used for impact effects. Footstep intervals
adjust dynamically based on character velocity (faster when sprinting, slower when sneaking).

Sounds that need to persist after entity removal are moved to the entity's parent node at the same position, with a
callback to remove them when finished playing.

### Movement System

Character movement has been refactored into a dedicated ECS system. Characters populate their velocity component, and the
movement system processes them based on body type (CharacterBody3D, RigidBody3D, or StaticBody3D). This allows consistent
movement handling across all character types including zombies and players.

### Skin System

The skin observer handles visual changes based on entity state. Health components can specify which skin to use based on
current health percentage. Each skin can:

- Change materials on mesh instances
- Enable/disable visual nodes
- Enable/disable collision shapes

This allows entities like breakable doors to transition between intact, damaged, and destroyed states with appropriate
visual and physical changes.

### Entity Utilities

The EntityUtils singleton provides helper functions for common entity operations:

- **Flammable check** - Determines if an entity can catch fire
- **Player check** - Identifies player entities for targeting and interactions
- **Entity removal** - Safe entity cleanup with sound persistence

These utilities are used throughout the codebase to maintain consistent entity handling across systems and observers.

## Roadmap

### In Progress

- Melee impact sounds
- Explosion decals

### Completed

- ~~Debug cheats (no clip, god mode, no aggro)~~
- ~~Ammo system with types and fire modes~~
- ~~Zombie horde following behavior~~

### Planned

- Stealth mechanics (door peeking, audio detection)
- Ranged zombie attacks
- Survivor AI (follow paths, follow player, flee)
- Public release with itch.io page
- Additional weapons (stick, rock throwing)
- Multiple weapon muzzle markers for alternating/simultaneous fire

## License

This project is licensed under the **GNU General Public License v3.0** (GPL-3.0), allowing use in similarly open-source
projects.

- **Code** - GPL-3.0
- **Shaders** - May be included under different licenses; see individual file headers for details
- **Assets** - Some 3D content uses paid asset packs (see asset documentation for attribution)

No AI-generated assets are used in this project.
