extends Component
class_name ZC_Objective

@export var end_game: bool = false
@export var win_game: bool = false
@export var load_level: bool = true
@export var next_level: String = ''

@export var is_active: bool = false:
  set(value):
    var previous_active := is_active
    is_active = value
    if previous_active != value:
      property_changed.emit(self, "is_active", previous_active, is_active)

@export var is_complete: bool = false:
  set(value):
    var previous_complete := is_complete
    is_complete = value
    if previous_complete != value:
      property_changed.emit(self, "is_complete", previous_complete, is_complete)
