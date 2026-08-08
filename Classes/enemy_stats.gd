extends Resource
class_name EnemyStats

@export var speed: float = 0.0
@export var gravity: float = 0.0

@export var max_health: float = 0
@export var current_health: float = 0

@export var damage: float = 0

@export var resists: Dictionary = {
	"fire": 0.1,
	"water": 0.1,
	"ice": 0.1,
	"wind": 0.1,
	"earth": 0.1,
	"light": 0.1,
	"dark": 0.1,
}

@export var unic_stats: Dictionary = {}
