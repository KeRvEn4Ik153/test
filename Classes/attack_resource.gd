extends Resource
class_name AttackData

@export var id: String = ""

@export_category("Visual & Audio")
@export var animation_name: String = ""

@export_category("Economy")
@export var mana_cost: float = 0.0
@export var cooldown: float = 0.0

@export_category("Combat Stats")
@export var damage: float = 0.0
@export var knockback_power: float = 0.0
@export var stun_time: float = 0.0
@export var type_damage: String = ""
@export var element_type: String = ""
@export var projectile_scene: PackedScene # Сцена файрбола (если есть)
@export var can_movement: bool = false

@export_category("Attack Detail")
@export var which_button_to_attack: String = ""
@export var after_which_attack: Array[String] = []
@export var change_attack: bool = false
@export var state_of_attack: String = "windup" # windup active recovery
