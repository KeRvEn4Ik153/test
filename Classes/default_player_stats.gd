extends Resource
class_name DefaultPlayerStatsData

signal health_changed(current, max_val)
signal mana_changed(current, max_val)

@export var speed: float = 0.0
@export var jump_velocity: float = 0.0

@export var dash_cooldown: float = 0.0
@export var dash_duration: float = 0.0
@export var dash_speed: float = 0.0

@export var get_damage_cooldown: float = 0.0

@export var max_health: float = 0
@export var health_regen: float = 0

@export var max_mana: float = 0
@export var mana_regen: float = 0

@export var crit_multiplier: float = 1.5
@export var crit_chance: float = 5.0

@export var damage_bonus: float = 0.0
@export var stacks: int = 0
@export var stack_bonus: float = 2.5

@export var current_health: float = 0.0:
	set(value):
		current_health = clamp(value, 0.0, max_health)
		health_changed.emit(current_health, max_health) 

@export var current_mana: float = 0.0:
	set(value):
		current_mana = clamp(value, 0.0, max_mana)
		mana_changed.emit(current_mana, max_mana) 

func get_damage_bonus():
	damage_bonus = stacks * stack_bonus	
	return damage_bonus
