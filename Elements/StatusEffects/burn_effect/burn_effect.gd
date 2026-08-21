extends StatusEffectData
class_name BurnEffect

var damage: float = 10.0

func _init(custom_duration: float, custom_damage: float) -> void:
	id = "burn"
	damage = custom_damage
	duration = custom_duration

func on_tick(player: CharacterBody2D) -> void:
	if "DPS" in player:
		player.take_player_damage(damage, 0.0, 0.0, "fire", "stun", player.position)
	if "enemy_stats" in player:
		player.take_damage(damage, 0.0, 0.0, "fire", "stun", player.position)
