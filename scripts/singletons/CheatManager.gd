extends Node

enum Cheats {
	NO_AGGRO,
	NO_CLIP,
	GOD_MODE,
}

var _state: Dictionary[Cheats, bool] = {}

func _toggle_no_aggro(_players: Array[Entity], _value: bool) -> void:
	pass

func _toggle_no_clip(players: Array[Entity], value: bool) -> void:
	for player in players:
		var character_player := player.get_node(".") as CharacterBody3D
		var physics_player := player.get_node(".") as PhysicsBody3D
		print("Enabling no-clip for player %s" % player.name)
		physics_player.set_collision_layer_value(4, not value)
		physics_player.set_collision_layer_value(8, value)
		physics_player.set_collision_mask_value(1, not value)
		physics_player.disable_mode = PhysicsBody3D.DISABLE_MODE_MAKE_STATIC
		if value:
			character_player.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
			physics_player.process_mode = PhysicsBody3D.PROCESS_MODE_DISABLED
		else:
			character_player.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
			physics_player.process_mode = PhysicsBody3D.PROCESS_MODE_INHERIT

		for child in physics_player.get_children():
			if child is CollisionShape3D:
				child.disabled = value

func _toggle_god_mode(_players: Array[Entity], _value: bool) -> void:
	pass

func toggle_cheat(cheat: Cheats, value: bool) -> void:
	_state[Cheats.NO_CLIP] = value

	var players := EntityUtils.get_players()
	match cheat:
		Cheats.NO_AGGRO:
			_toggle_no_aggro(players, value)
		Cheats.NO_CLIP:
			_toggle_no_clip(players, value)
		Cheats.GOD_MODE:
			_toggle_god_mode(players, value)

func get_cheat_state(cheat: Cheats) -> bool:
	return _state.get(cheat, false)
