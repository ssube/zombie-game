extends Area3D

@export var active: bool = true
@export var require_line_of_sight: bool = true

@export_group("Regular Damage")
@export var apply_damage: bool = true
@export var damage_amount: int = 10

@export_group("Fire Damage")
@export var apply_fire: bool = false
@export var fire_duration: float = 5.0

@export_group("Physics")
@export var apply_force: bool = true
@export var force_multiplier: float = 0.2

@export_group("Factions")
@export var damage_players: bool = true
@export var damage_enemies: bool = true

var body_queue: Array[Node] = []
var sight_queue: Array[Node] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if require_line_of_sight:
		if body not in body_queue:
			body_queue.append(body)
	else:
		# skip line of sight check, append directly to sight queue
		if body not in sight_queue:
			sight_queue.append(body)


func _physics_process(_delta: float) -> void:
	if not require_line_of_sight:
		return

	var space_state := get_world_3d().direct_space_state
	var root_pos := self.global_position

	for body in body_queue:
		if body is Node3D:
			var query := PhysicsRayQueryParameters3D.create(root_pos, body.global_position)
			var result := space_state.intersect_ray(query)
			var collider = result.get("collider")
			if collider == null:
				continue

			print("Colliding with: ", collider)
			if collider == body:
				# TODO: handle child nodes
				sight_queue.append(body)

	body_queue.clear()


func _process(_delta: float) -> void:
	for body in sight_queue:
		apply_effects(body)

	sight_queue.clear()


func apply_effects(body: Node) -> void:
	if apply_force:
		physics_force(body)

	if body is Entity:
		if body.has_component(ZC_Player):
			if not damage_players:
				return # Don't damage the player
		else:
			if not damage_enemies:
				return # Don't damage enemies

		if apply_damage:
			regular_damage(body)

		if apply_fire:
			fire_damage(body)


func regular_damage(body: Entity) -> void:
	if body.has_component(ZC_Health):
		body.add_relationship(RelationshipUtils.make_damage(damage_amount))
		print("Applied ", damage_amount, " damage to ", body)


func fire_damage(body: Entity) -> void:
	if body.has_component(ZC_Flammable):
		var fire := ZC_Effect_Burning.new()
		fire.time_remaining = fire_duration
		body.add_component(fire)
		print("Fire spread to: ", body)


func physics_force(body: Node) -> void:
	if body is RigidBody3D:
		var force = body.mass * force_multiplier
		body.apply_impulse(Vector3(0, force, 0), self.global_position)
