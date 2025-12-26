extends ZB_State
class_name ZB_State_Chase

@export var chase_timeout: float = 15.0
@export var navigation_interval: float = 1.0
@export var navigation_timer: float = 0.0
@export var point_proximity: float = 1.0

var navigation_path: PackedVector3Array = []

func tick(entity: Entity, delta: float, _behavior: ZC_Behavior) -> TickResult:
		var attention := entity.get_component(ZC_Attention) as ZC_Attention
		if attention == null or not attention.has_target_position:
				return TickResult.FORCE_EXIT

		if OptionsManager.options.cheats.no_aggro:
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

		var movement := entity.get_component(ZC_Movement) as ZC_Movement
		movement.target_look_position = target_position

		var node_3d := entity.root_3d as Node3D
		NavigationUtils.follow_navigation_path(node_3d, navigation_path, point_proximity)

		navigation_timer -= delta
		if navigation_timer > 0.0:
				return TickResult.CONTINUE

		navigation_timer = navigation_interval
		navigation_path = NavigationUtils.update_navigation_path(node_3d, target_position)
		return TickResult.CONTINUE
