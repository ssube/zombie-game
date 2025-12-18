extends Component
class_name ZC_Skin

enum SkinType {
	HEALTHY,
	HURT,
	DEAD,
	ENABLED,
	DISABLED,
}

@export_group("Materials")
@export_subgroup("Health")
@export var material_healthy: BaseMaterial3D = null
@export var material_hurt: BaseMaterial3D = null
@export var material_dead: BaseMaterial3D = null

@export_subgroup("State")
@export var material_disabled: BaseMaterial3D = null
@export var material_enabled: BaseMaterial3D = null

@export_group("Nodes")
@export var skin_shapes: Array[NodePath] = []

@export_group("State")
@export var current_skin: SkinType = SkinType.HEALTHY:
	set(value):
		var old_skin := current_skin
		current_skin = value
		if old_skin != current_skin:
			property_changed.emit(self, "current_skin", old_skin, current_skin)
