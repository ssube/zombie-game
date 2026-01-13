extends Component
class_name ZC_Equipment

enum EquipmentPhysicsMode {
	DISABLED,
	STATIC,
	KINEMATIC,
	ENABLED,
}

@export var droppable: bool = true
@export var equippable: bool = true
@export var slot: String = ""
@export var physics_mode: EquipmentPhysicsMode = EquipmentPhysicsMode.STATIC
