extends ZM_BaseMenu

@export var hints: Array[String] = [
	"Zombies are bad for your health.",
	"Zombies are usually green.",
	"Zombies do not like being shot in the head.",
]
@export var hint_index: int = 0
@export var hint_interval: float = 10.0
@export var hint_label: Label

var hint_timer: float = 0.0

signal hint_shown(hint: String)


func on_update() -> void:
	pass


func _process(delta: float) -> void:
	if not self.visible:
		return
		
	hint_timer += delta
	if hint_timer > hint_interval:
		hint_index = (hint_index + 1) % hints.size()
		hint_label.text = hints[hint_index]
		hint_shown.emit(hints[hint_index])
