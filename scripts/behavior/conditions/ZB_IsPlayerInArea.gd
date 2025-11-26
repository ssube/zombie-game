@tool
extends ConditionLeaf
class_name ZB_IsPlayerInArea

enum DetectionMode { FIRST, NEAREST }

@export var detection_mode: DetectionMode = DetectionMode.FIRST
@export var detection_area: Area3D = null


func _ready() -> void:
	if detection_area == null:
		printerr("Behavior node missing detection area: ", self)


func tick(actor: Node, blackboard: Blackboard) -> int:
	if ECS.world == null:
		return FAILURE

	if detection_area == null:
		return FAILURE

	var actor3d = actor as Node3D
	var target_player: Node3D = null

	if detection_mode == DetectionMode.FIRST:
		target_player = find_first_player()
	elif detection_mode == DetectionMode.NEAREST:
		target_player = find_nearest_player(actor3d)
	else:
		printerr("Unknown detection mode: ", detection_mode)

	if target_player == null:
		return FAILURE

	blackboard.set_value("target_player", target_player)
	return SUCCESS


func find_players() -> Array[Node3D]:
	var players: Array[Node3D] = []
	for body in detection_area.get_overlapping_bodies():
		var body_root = body.get_node(".")
		if body_root is Entity:
			if body_root.has_component(ZC_Player):
				players.append(body)

	return players


func find_first_player() -> Node3D:
	var players := find_players()
	if len(players) > 0:
		return players[0]

	return null


func find_nearest_player(actor3d: Node3D) -> Node3D:
	var players := find_players()
	if len(players) == 0:
		return null

	var nearest_distance: float = INF
	var nearest_player: Node3D = null

	for player in players:
		var player_distance := actor3d.global_position.distance_squared_to(player.global_position)
		if player_distance < nearest_distance:
			nearest_distance = player_distance
			nearest_player = player

	return nearest_player
