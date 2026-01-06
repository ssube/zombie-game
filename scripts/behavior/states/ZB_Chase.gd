extends ZB_State
class_name ZB_State_Chase

@export var chase_timeout: float = 15.0
@export var navigation_interval: float = 1.0
@export var navigation_timer: float = 0.0
@export var point_proximity: float = 1.0

var navigation_path: PackedVector3Array = []

func tick(entity: Entity, delta: float, _behavior: ZC_Behavior) -> TickResult:
		var attention := entity.get_component(ZC_Attention) as ZC_Attention
		if attention == null:
				return TickResult.FORCE_EXIT

		var movement := entity.get_component(ZC_Movement) as ZC_Movement
		if movement == null:
				return TickResult.FORCE_EXIT

		if not attention.has_target_position:
				return TickResult.FORCE_EXIT

		if OptionsManager.options.cheats.no_aggro:
			return TickResult.FORCE_EXIT

		# try to find a valid weapon if we don't have one
		var wielding := RelationshipUtils.get_wielding(entity)
		if wielding.size() == 0:
				switch_weapon(entity)

		# if there are still no more weapons after switching
		wielding = RelationshipUtils.get_wielding(entity)
		if wielding.size() == 0:
				return TickResult.FORCE_EXIT

		# Chase can work with just a position (heard a sound) or with an entity
		var target_position: Vector3 = attention.target_position

		# If we have a target entity and can see it, update position to current
		if attention.has_target_entity:
				var target_entity := ECS.world.get_entity_by_id(attention.target_entity)
				if target_entity != null:
						var perception := entity.get_component(ZC_Perception) as ZC_Perception
						if perception != null and attention.target_entity in perception.visible_entities:
								target_position = target_entity.global_position
								attention.target_position = target_position  # Keep attention updated

		var node_3d := entity.root_3d as Node3D
		navigation_path = NavigationUtils.follow_navigation_path(node_3d, navigation_path, point_proximity)

		navigation_timer -= delta
		if navigation_timer > 0.0:
				return TickResult.CONTINUE

		navigation_timer = navigation_interval
		navigation_path = NavigationUtils.update_navigation_path(node_3d, target_position)
		movement.set_move_target(target_position) # TODO: check if this should use the navigation path
		return TickResult.CONTINUE


func switch_weapon(entity: Entity) -> ZE_Weapon:
		if entity is not ZE_Character:
				return null

		var inventory := RelationshipUtils.get_weapons(entity)
		for item in inventory:
			var broken := EntityUtils.is_broken(item)
			if not broken:
				EntityUtils.equip_weapon(entity, item)
				return item as ZE_Weapon

		return null
