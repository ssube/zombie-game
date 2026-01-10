extends RefCounted
class_name ActionContext
## Encapsulates the context for an action execution, including the action event type,
## trigger and subject actors, the menu state, and arbitrary action data.


## Represents an actor involved in an action (either trigger or subject).
## Contains references to the underlying entity, physics body, node hierarchy, and collision shape.
class ActionRef extends RefCounted:
	## The Entity component representing this actor (if applicable).
	var entity: Entity

	## The PhysicsBody3D node this actor is associated with (if applicable).
	var body: PhysicsBody3D

	## The general Node reference for this actor (can be any node type).
	var node: Node

	## The CollisionShape3D node associated with this actor (if applicable).
	## This will only be populated if the action was triggered by a raycast hit, otherwise the shape is not known.
	var shape: CollisionShape3D


	static func from_node(source: Node) -> ActionRef:
		var actor := ActionRef.new()
		actor.node = source
		if source is Entity:
			actor.entity = source
		elif source is PhysicsBody3D:
			actor.body = source
		return actor


## Represents the menu state and UI control associated with an action.
class ActionMenu extends RefCounted:
	## The base menu instance (ZM_BaseMenu) if a menu is active.
	var menu: ZM_BaseMenu

	## The Control node representing the UI element that was interacted with.
	var control: Control


## The type of action event being executed.
var event: Enums.ActionEvent

## The actor initiating the action.
var trigger: ActionRef = null

## The actor targeted by the action.
var subject: ActionRef = null

## The menu context associated with this action (if applicable).
var menu: ActionMenu = null

## Arbitrary key-value data storage for action-specific parameters and state.
var data: Dictionary[String, Variant] = {}
