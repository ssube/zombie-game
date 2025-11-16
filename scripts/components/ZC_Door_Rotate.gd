extends ZC_Door
class_name ZC_Door_Rotate

## Rotate both ways, away from the player
@export var rotate_away: bool = false
@export var open_rotation: Vector3 = Vector3.ZERO
@export var open_rotation_2: Vector3 = Vector3.ZERO
# @onready var close_rotation: Vector3 = self.global_rotation
