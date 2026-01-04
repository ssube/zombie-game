extends Observer
class_name ZO_PortalObserver


func watch() -> Resource:
	return ZC_Portal


func on_component_changed(_entity: Entity, component: Resource, property: String, new_value: Variant, _old_value: Variant):
	var portal := component as ZC_Portal
	if property == 'is_active':
		if new_value:
			ZombieLogger.debug("Portal is active, loading level: {0}", [portal.next_level])
			var game := TreeUtils.get_game(self)
			game.load_level(portal.next_level, portal.spawn_point)
