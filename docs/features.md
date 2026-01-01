# Zombie Game - Feature List

## Combat

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

## Weapons

- Baseball bat (melee)
- Shotgun (ranged)
- Crowbar (melee with metal impact sounds)
- Rave shotgun (ranged with RGB gradient lighting effects)
- Throwable flare that ignites flammable objects
- Weapon equip and use sounds
- Weapon effects system (muzzle flash, etc.)
- Melee weapon durability system with surface-based damage
- Weapon broken/empty sound effects
- Ammo system with pickup, reload, and consumption
- Ammo counter displays current, max, and spare ammunition
- Weapon holster action
- Partial ammo pickup (leaves remainder if inventory full)
- Thrown weapons automatically unequip when out of ammo
- Melee weapon animations/paths on character (not weapon)
- Adaptive aim system (weapon points at raycast collision)
- Adaptive aim lerp speed option with slider

## Enemies

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

## Environment

- Interactive doors with auto-close and proximity triggers
- Multiple door types: standard rotating, breakable, automatic sliding
- Fire and burning mechanics (spreads, resets timer)
- Water areas with movement speed modifiers
- Water extinguishes fires
- Flammable entities and environmental fire damage
- Surface type system integrated with Trenchbroom/func_godot
- Bullet and impact decals based on surface type
- Breakable glass with particle effects and sounds
- Interactive buttons (push/toggle with auto-reset)
- Pressure plates for triggering actions
- Dripping water prefabs
- Locks and keys separated from door system (can lock anything)
- Path-following entities (cars, seagulls) with damage areas and sounds
- Barrel of fire prop
- Static props (stop signs, mailboxes)
- Grass clusters with mixed texture/mask rendering
- Physics body with controllable buoyancy

## Screen Effects

- Hit indicator
- Low health vignette
- Underwater distortion with scrolling shader
- Fire and acid/poison effects
- Rain and thunder effects
- Support for multiple simultaneous effects with fade in/out
- Armor and healing effects
- Effect strength curves for customizable fade behavior
- Screen effect expiration system with automatic fade-out
- Support for overlapping effects with same type
- Temporary and persistent effect durations
- Vignette softness limits to prevent hard edges

## NPCs and Dialogue

- Friendly survivor characters
- Dialogue system with trees and random clips
- Character rotation tweening for conversations
- Dialogue commands (look at player, look at marker)
- Dialogue integrated with game HUD (hides HUD during conversations)
- Dialogue captures input without pausing game
- Faction system for identifying enemies, friendlies, and players

## Levels and Maps

- FuncGodot integration for Quake-style brush mapping
- Level switching with named player spawn points
- Level select menu
- Unique entity IDs per level
- Entity grouping by room for organization
- Occlusion culling support
- Campaign resource system with level metadata
- Loading screen images and level-specific hints
- Loading hints shuffle randomly on each level load
- CLI arguments for selecting debug level and spawn point
- Fallback spawn point support

## Inventory and Items

- Inventory system linked via ECS relationships
- Equipment slots system with visible items attached to 3D markers
- Flashlight as equippable item
- Medkits with health subtypes (food, medical, magic)
- Keys and locked doors/containers
- Armor pickups
- Equippable hats (traffic cone, fishing hat)
- Item shimmer effect for interactive objects
- Use items from inventory menu
- Inventory items hidden and physics disabled when carried
- Inventory items follow player in 3D space
- Item pickup, equip, and use sounds

## Objectives

- Objective tree system
- Counter objectives (e.g., "blast 20 zombies")
- Completion triggers: on interaction, damage, or death
- Active objective display in HUD
- Objective status persistence

## Controls

- Mouse look with capture management
- Controller support
- Flashlight toggle
- Weapon holster and reload actions
- Inventory and objectives menu shortcuts
- Item pickup without immediate consumption
- Improved character controller (IKCC) for walking up curbs and stairs

## Menus and UI

- Main menu, pause menu, settings menu
- Loading screen with gameplay hints that fade in/out
- Loading screen blocks menu shortcuts during load
- Game over screen with killer entity name display
- Player health bar synced on start
- Current weapon and ammo display (hidden for melee, shows durability for melee)
- Current objective in HUD
- Debug menu with framerate display
- Cheats menu with no-clip mode
- Inventory menu with double-click to use
- Objectives menu with active objective switching
- Exit confirmation with natural duration format since last save
- Exit vs quit button clarification (exit to main menu, quit to desktop)
- New save name prompts and overwrite confirmation
- Saves sorted by date
- Shader toggle in pause menu
- Menu audio volume slider
- Menu shortcuts to controls and options
- Hidden menus have processing disabled for performance
- Auto-focus on save game name input when dialog opens

## Save System

- Level state persistence
- ECS relationship persistence
- Entity deletion tracking across saves
- Spawned entity prefab path tracking
- Current level and spawn point persistence
- Options save/load
- Objective status saving
- Save files stored in user directory

## Audio

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
- Menu background audio with two-part ambient loop
- Menu button click sounds
- Dialogue response button click sounds
- Subtitle system for accessibility
- Noise component for subtitle generation
- Multiple sound support in audio actions (random/all play modes)

## Physics

- Collision layers: world, props, items, player, enemies
- Character body support (static and rigid bodies)
- Support for entities with multiple physics bodies
- Gimbal node for maintaining rotation with configurable resistance
- Continuous collision detection for fast-moving projectiles

## Actions and Triggers

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
- Raycast area for line-of-sight based triggers

## Custom Nodes

- Light group node (enable/disable groups of lights)
- Remote transform node with multiple targets and disable capability
- Remote transform standby markers for disabled state
- Audio button scene with automatic click sound playback
