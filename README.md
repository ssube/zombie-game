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

### Weapons

- Baseball bat with swing-activated damage areas
- Shotgun with projectile impacts
- Weapon equip and use sounds
- Weapon effects system (muzzle flash, etc.)

### Enemies

- Zombie AI using finite state machines
- Vision cone detection system
- Navigation mesh pathfinding
- Wander and chase behaviors
- Zombie variants (flashlight zombie worker)

### Environment

- Interactive doors with auto-close and proximity triggers
- Fire and burning mechanics (spreads, resets timer)
- Water areas with movement speed modifiers
- Flammable entities and environmental fire damage
- Bullet and impact decals based on surface type

### Screen Effects

- Hit indicator
- Low health vignette
- Underwater distortion with scrolling shader
- Fire and acid/poison effects
- Support for multiple simultaneous effects with fade in/out

### NPCs and Dialogue

- Friendly survivor characters
- Dialogue system with trees and random clips
- Character rotation tweening for conversations
- Dialogue commands (look at player, look at marker)

### Levels and Maps

- FuncGodot integration for Quake-style brush mapping
- Level switching with named player spawn points
- Unique entity IDs per level
- Entity grouping by room for organization
- Occlusion culling support

### Inventory and Items

- Inventory system linked via ECS relationships
- Medkits with health subtypes (food, medical, magic)
- Keys and locked doors/containers
- Armor pickups
- Item shimmer effect for interactive objects
- Use items from inventory menu

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
- Loading screen with gameplay hints
- Game over screen
- Player health bar synced on start
- Current weapon and ammo display (hidden for melee)
- Current objective in HUD
- Debug menu with framerate display
- Cheats menu
- Inventory menu with double-click to use
- Objectives menu with active objective switching
- Exit confirmation with time since last save
- New save name prompts and overwrite confirmation
- Saves sorted by date

### Save System

- Level state persistence
- Options save/load
- Objective status saving
- Save files stored in user directory

### Audio

- Weapon fire and impact sounds
- Explosion sounds
- Footstep sounds based on surface material
- Impact sounds based on surface type
- Item pickup and use sounds
- Subtitle system for accessibility

### Physics

- Collision layers: world, props, items, player, enemies
- Character body support (static and rigid bodies)
- Surface type detection for effects and sounds

## Addons

- **Debug Menu** - Framerate and frame time display
- **Dialogue Manager** - Dialogue randomization and conversation trees
- **Func Godot** - Quake-style map import from Trenchbroom
- **GECS** - Entity Component System framework
- **VisionCone3D** - Vision cone checks for AI detection
- **Zombie Tools** - Custom editor tools (collision shape fixing, etc.)

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

- **Metal** - Sparks and metallic ping sounds
- **Wood** - Splinters and thud sounds
- **Flesh** - Blood splatter and organic impact sounds
- **Zombie** - Green goo and squelch sounds

Impact decals are aligned with the surface normal of the hit location. Decals use the Sprite3D class to support Godot's
compatibility renderer.

### Surface Type Detection

Collision helpers provide surface type detection used by both the impact effects and footstep systems. Surface types can
be assigned via collision shape metadata.

The surface metadata is not fully integrated into the func_godot import pipeline yet.

The global DecalManager maintains a lookup table mapping surface types to their corresponding decal scenes and impact
sounds.

### Sound Management

Footsteps are handled by an ECS system, using the same surface type detection used for impact effects.

Sounds that need to persist after entity removal are moved to the entity's parent node at the same position, with a
callback to remove them when finished playing.

## Roadmap

### In Progress

- Debug cheats (no clip, god mode, no aggro)
- Melee impact sounds
- Explosion decals
- Inventory item stacks and groups
- Ammo system with types and fire modes

### Planned

- Stealth mechanics (door peeking, audio detection)
- Ranged zombie attacks
- Zombie horde following behavior
- Survivor AI (follow paths, follow player, flee)
- Public release with itch.io page

## License

This project is licensed under the **GNU General Public License v3.0** (GPL-3.0), allowing use in similarly open-source
projects.

- **Code** - GPL-3.0
- **Shaders** - May be included under different licenses; see individual file headers for details
- **Assets** - Some 3D content uses paid asset packs (see asset documentation for attribution)

No AI-generated assets are used in this project.
