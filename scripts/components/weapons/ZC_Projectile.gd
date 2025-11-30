extends Component
class_name ZC_Projectile


@export var velocity: Vector3 = Vector3.ZERO
@export var damage: float = 10.0
@export var lifetime: float = 5.0
@export var collision_ray: NodePath = "."
@export var piercing: int = 0
@export var mass: float = 1.0