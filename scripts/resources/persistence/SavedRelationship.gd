extends Resource
class_name ZP_SavedRelationship

enum TargetType {
	ENTITY,
	COMPONENT
}

@export var relation: ZP_SavedComponent

@export_group("Target")
@export var target_type: TargetType
@export var target_entity_id: String
@export var target_component: ZP_SavedComponent
