extends ZB_Condition
class_name ZB_IsPlayerInArea

enum DetectionMode { FIRST, NEAREST }

@export var detection_area: Area3D = null
@export var detection_mode: DetectionMode = DetectionMode.FIRST


func _ready() -> void:
	if detection_area == null:
		ZombieLogger.error("Behavior node missing detection area: {0}", [self.get_path()])


func test(actor: Node, _delta: float, behavior: ZC_Behavior) -> bool:
	if ECS.world == null:
		return false

	if detection_area == null:
		return false

	var actor3d = actor as Node3D
	var target_player: Node3D = null

	if detection_mode == DetectionMode.FIRST:
		target_player = find_first_player()
	elif detection_mode == DetectionMode.NEAREST:
		target_player = find_nearest_player(actor3d)
	else:
		ZombieLogger.error("Unknown detection mode: {0}", [detection_mode])

	if target_player == null:
		return false

	behavior.set_value("target_player", target_player.id)
	return true


func find_players() -> Array[Node3D]:
	var players: Array[Node3D] = []
	for body in detection_area.get_overlapping_bodies():
		var body_root = body as Node
		if body_root is Entity:
			if EntityUtils.is_player(body_root):
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
