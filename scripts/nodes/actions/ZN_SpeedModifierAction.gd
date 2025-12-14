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


func run_entity(actor: Entity, _area: ZN_TriggerArea3D, event: ZN_TriggerArea3D.AreaEvent) -> void:
	match event:
		ZN_TriggerArea3D.AreaEvent.BODY_ENTER:
			apply_multiplier(actor)
		ZN_TriggerArea3D.AreaEvent.BODY_EXIT:
			remove_multiplier(actor)


func apply_multiplier(body: Entity) -> void:
	print("Slowing entity: ", body)
	body.add_relationship(RelationshipUtils.make_modifier_speed(speed_multiplier))

func remove_multiplier(body: Entity) -> void:
	print("Restoring entity speed: ", body)
	body.remove_relationship(remove_query, 1)
