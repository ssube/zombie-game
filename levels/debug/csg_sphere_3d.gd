extends CSGSphere3D

@export var albedo_color: Color = Color.DARK_RED

func _ready() -> void:
	if self.material is StandardMaterial3D:
		var mat := self.material as StandardMaterial3D
		mat = mat.duplicate()
		mat.albedo_color = albedo_color
		self.material = mat
