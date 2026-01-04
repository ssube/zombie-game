extends TabContainer

@export var audio_player: AudioStreamPlayer = null


func _ready() -> void:
	self.tab_clicked.connect(_on_tab_clicked)


func _on_tab_clicked(_tab: int) -> void:
	if audio_player:
		audio_player.play()
