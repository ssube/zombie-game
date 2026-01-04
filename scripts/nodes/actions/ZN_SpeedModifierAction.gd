extends ZN_BaseAction
class_name ZN_SpeedModifierAction

@export var speed_multiplier: float = 1.0

@onready var remove_query = Relationship.new(
	ZC_Modifier.new(),
	{
		ZC_Effect_Speed: {
			"multiplier": {
				"_eq": speed_multiplier,
			}
		}
	}
)


func run_entity(_source: Node, event: Enums.ActionEvent, actor: Entity) -> void:
	match event:
		Enums.ActionEvent.BODY_ENTER:
			apply_multiplier(actor)
		Enums.ActionEvent.BODY_EXIT:
			remove_multiplier(actor)


func apply_multiplier(body: Entity) -> void:
	ZombieLogger.debug("Slowing entity: {0}", [body.get_path()])
	body.add_relationship(RelationshipUtils.make_modifier_speed(speed_multiplier))

func remove_multiplier(body: Entity) -> void:
	ZombieLogger.debug("Restoring entity speed: {0}", [body.get_path()])
	body.remove_relationship(remove_query, 1)
