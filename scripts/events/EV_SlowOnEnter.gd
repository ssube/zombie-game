extends Area3D

@export var speed_modifier: float = 0.5

var remove_query = Relationship.new(
	ZC_Modifier.new(),
	{
		ZC_Effect_Speed: {
			"multiplier": {"_eq": speed_modifier}
		}
	}
)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body is Entity:
		print("Slowing entity: ", body)
		body.add_relationship(RelationshipUtils.make_modifier_speed(speed_modifier))

func _on_body_exited(body: Node) -> void:
	if body is Entity:
		print("Restoring entity speed: ", body)
		body.remove_relationship(remove_query, 1)
