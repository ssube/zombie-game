extends Component
class_name ZC_Portal

## Portal can be used
@export var is_open: bool = true
## Portal is being used
@export var is_active: bool = false:
  set(value):
    var previous_active := is_active
    is_active = value
    property_changed.emit(self, "is_active", previous_active, is_active)


## Next level to load
@export var next_level: String = ''
## Starting location in the next level
@export var spawn_point: String = ''