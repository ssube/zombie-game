# Zombie Game

A Quake 3 style zombie shooter set in a small town, built with Godot and an Entity Component System architecture. Open source code with paid assets.

## Features

For a complete list of features, see [docs/features.md](docs/features.md).

### Highlights

- **Dynamic Health and Stamina Systems** - Manage your resources carefully as you sprint, fight, and survive. Health regenerates slowly while stamina drains with every action, creating tactical choices in combat.
- **Full Persistence with ECS** - Built on GECS with complete save/load support including entity relationships and deletion tracking. Your progress persists exactly as you left it, down to which zombies you've eliminated.
- **Mod-Friendly Custom Levels** - Create your own campaigns using Trenchbroom's Quake-style brush mapping through FuncGodot integration. Build entire towns with minimal setup and automatic surface type detection.
- **Physics-Based Combat** - Every weapon uses precise physics with accurate hitboxes. Bullets trace realistic paths, melee weapons only damage during swing animations, and explosions check line-of-sight.
- **Visible Equipment System** - Equip weapons, flashlights, and cosmetic items that attach to 3D markers on your character. See your gear in real-time as you switch between tools and weapons.
- **Node-Based Interaction System** - Build complex triggers and actions with visual node trees. Add interactive doors, pressure plates, timed events, and custom behaviors without writing code.
- **Intelligent Zombie AI** - Zombies use finite state machines integrated with the ECS architecture, complete with persistent blackboards for memory. They hunt, wander, and swarm based on what they see and hear.
- **Branching Survivor Dialogue** - Encounter friendly survivors with full dialogue trees powered by Dialogue Manager. NPCs react to your choices and remember previous conversations.

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
