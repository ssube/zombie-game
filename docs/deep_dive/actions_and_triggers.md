Early in development of Zombie Game, I noticed that the code had already accumulated about 7 different scripts that had a lot of overlapping functionality. For example, there was a DamageOnEnter script and a BurnOnEnter script, which were identical except for the component or relationship that they applied when an actor entered the area. They connected to the same events, and used the same logic, but changed different variables in different components or added different relationships to the actor.

At the same time, I started building objective trees for the levels. It was often useful to have an objective run some small actions, like unlocking a door, removing an obstacle or roadblock from the map, or some other small modification of the ECS world.

Looking at all of the classes that had accumulated, I had:

- 3 nearly identical areas:
	- TriggerArea3D - the only class that survived
		- had flags for: damage, fire, physics impulse
		- with a flag for whether line-of-sight was required
	- EffectArea3D - like trigger area but only for screen effects (the red overlay when you're hit, the green for healing, blue when you're underwater, etc)
	- SpeedModifierArea3D - like trigger and effect but only for speed modifiers
- 4 of what I was calling events:
	- burn on timer
	- damage on enter
	- damage on timer
	- remove after timer

This got me thinking about how to prevent more duplication and the bugs that would arise from having a dozen classes doing very similar things. The best solution that I came up with was to separate the triggers and their actions into separate nodes, so that I could place action nodes into an area or objective and they would run when that area was triggered by the physics system or when the objective was completed.

Objectives already had some action nodes for simple tasks like unlocking a door, which gave me a place to start. I wanted to refactor the areas into something that would work with the same actions, allowing me to build geometry that ran code without repeating the basic signal bindings across a dozen different scripts.

I set up a few more actions, gave them a signature that could be called by areas or objectives, and started building. After reviewing where they could be used in the game, I found:

- damage areas for weapons and explosions
- fire areas in the environment
- screen effect areas for water, fire, etc
- speed modifier areas for water
- for objectives:
	- unlocking a door
	- removing an NPC or other entity

They even solved a few use-cases that I had in mind but had not used in the game yet, like spawning a zombie behind you after you enter a one-way hallway or other trap.

After a few attempts to figure out the naming convention and method signature, I settled on the following:

- `Actions` make some change to the ECS world or scene tree
- `Conditions` limit when actions will run
- `Objectives` are nodes that invoke actions when they are completed
- `Triggers` are 3D nodes that invoke actions based on their signals

This provides a flexible, node-based system for setting up actions in the world. The triggers are all somewhat generic, providing flags for each of the interesting signals they might emit. When a trigger event occurs, the actions within that trigger are run. Each action can have zero or more conditions, and the action only runs if the nested conditions all return true (AND logic). There is a branch "action" that creates a new branch of nodes, which can have its own conditions, allowing for some OR logic (a failing test in the first branch will not prevent the second branch from running) or acting as a sort of function name.

![[Screenshot_2025-12-17_17-11-14.png]]

In the example above, the `GlassSheet` entity has an `Actions` component, which points to the `BranchAction` for the `ENTITY_DEATH` event (the glass sheet also has health, so it can die). When the glass is broken, it spawns 3 particle effects are random locations around a marker, then starts the `TriggerTimer` node which removes the entity a moment later. That leaves some particles falling to the ground, but removes the visual and collision meshes for the sheet of glass, letting you climb through the window.

In the current version as of Dec 17 2025, the available nodes are:

- Actions: play animation, enable/disable an area, play audio, change the state of the behavior FSM, open/close a door, lock/unlock an entity, ignite/extinguish fire on an entity, apply a physics force, apply/remove a screen effect, spawn a scene, remove a node or entity from the world, apply a movement modifier to a character, or start a timer
- Actions that modify other actions: branch, delay, and call (run another action node selected in the editor)
- Conditions: filter by event type, filter by character faction
- Objectives: count and flag
- Triggers:
	- trigger area from before that runs its actions when a body enters, exits, or on an interval
	- raycast trigger area runs its actions when it has line-of-sight to a body within its 3D area
	- raycast trigger (just a regular raycast, no area) that runs its actions on collision, like a tripwire
	- timer trigger that runs its actions when it times out

Using these, I was able to build a bunch of different prefabs without writing code for any specific entity:

- ammo spawn box, which spawns an ammo crate every few seconds
- zombie spawn box, which spawns a zombie every few seconds
- pressure plate trap, which runs its actions when a character steps on it and moves down into the floor
- breakable doors, which took a little bit of code in the skin system
- breakable glass, shown in the example above

After trying to set up actions with event-specific fields on the parent (trigger) script, I decided that it would be cleaner to set up actions as a component and let each observer or system in the ECS world handle applying actions when a change occurred. For example, the door observer can run the `DOOR_OPEN` actions when it sees the `is_open` property change to true, and run the `DOOR_CLOSE` actions when it sees the property become false.

Because the actions were a component on the entity, I then ran into the same problems that I did with other components. Some actions could be defined within the prefab, but others might need to affect other prefabs in the level, and the component could only be applied once. If the extra level components had its own action component, that would completely replace the one in the prefab, but the level actions didn't have access to the nodes within the prefab to apply animations, play sounds, etc.

The answer for now is an `ExtraActions` component that is meant exclusively for use in the extra components list, typically within the level scene. This is a second component type that inherits from the regular `Actions` component and doesn't make any changes, but it allows the ECS system to have two different components for dictionary key purposes. I want to find a way to combine them at runtime to simplify running the actions, but the current helper is pretty simple:

```
static func run_entity(entity: Entity, event: Enums.ActionEvent, actor: Node) -> void:
	var actions := entity.get_component(ZC_Action) as ZC_Action
	if actions:
		ActionUtils.run_component(actions, entity, event, actor)
	
	var extra_actions := entity.get_component(ZC_ExtraAction) as ZC_ExtraAction
	if extra_actions:
		ActionUtils.run_component(extra_actions, entity, event, actor)
```

This lets you decide whether to replace the actions or add more while building the level scenes, and the same actions are available within the prefab, while building the level, and for objectives.

Because most of the nodes are responding to signals or timers, they only run after some events has occurred and take up very few resources. Performance is good with no measurable difference from the duplicate scripts, and the only theoretical overhead is some iteration through the actions (which are cached in `_ready`) and the function calls to `_run` those actions.

I know opinions can be divided on visual programming, but I found myself copy-pasting the same code into 5+ nearly identical scripts. That was already becoming a maintenance nightmare and I wanted to put a stop to that. This system uses a short method signature with 3 parameters and has already been used for buttons, doors, enemies, and other props within my zombie game's world.