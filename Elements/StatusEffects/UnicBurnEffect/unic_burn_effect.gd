class_name UnicBurnEffect
extends StatusEffectData

var damage_multiplier: float = 0.0
# Переменная для хранения величины бонуса к урону (например, 20.0 для +20%)
var attack_bonus_amount: float = 0.0 

func _init(custom_duration: float, percentage: float, bonus_dmg: float) -> void:
	id = "poison"
	duration = custom_duration
	damage_multiplier = percentage / 100
	attack_bonus_amount = bonus_dmg

# 1. Когда яд накладывается — увеличиваем бонус урона в ресурсе статов
func on_start(player: CharacterBody2D) -> void:
	if "damage_bonus" in player.DPS:
		player.DPS.damage_bonus += attack_bonus_amount

# Раз в секунду продолжаем бить по ХП
func on_tick(player: CharacterBody2D) -> void:
	var damage = ceil(player.DPS.max_health * damage_multiplier)
	var final_damage: float = float(damage)
	final_damage = max(1, final_damage)
	player.DPS.current_health -= final_damage

# 2. Когда яд заканчивается — забираем бонус обратно
func on_end(player: CharacterBody2D) -> void:
	player.DPS.damage_bonus -= attack_bonus_amount
