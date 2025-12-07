extends Component
class_name ZC_Food

enum Subtype { FOOD, MEDICAL, MAGIC }

@export var health: int = 10
@export var subtype: Subtype = Subtype.FOOD
