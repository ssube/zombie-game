extends Component
class_name ZC_Killstreak

## Records how many times each streak level was reached
## Key: streak size (2 = double kill, 3 = triple kill, etc)
## Value: number of times that streak level was reached
@export var streak_records: Dictionary[int, int] = {}

## Current killstreak count
@export var current_streak: int = 0
