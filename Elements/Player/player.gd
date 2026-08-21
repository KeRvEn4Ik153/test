extends CharacterBody2D
class_name Player

var dash_cooldown_timer: float = 0.0

@onready var hud: Control = $"../CanvasLayer/HUD"
@onready var current_style: Node2D = $CurrentSlot
@onready var camera: Camera2D = $Camera2D
@onready var animation_sprites: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: Node = $StateMachine
@onready var effect_manager: Node2D = $EffectManager
@onready var style_manager: Node2D = $StyleManager

@onready var player_stats: DefaultPlayerStatsData = load("res://Elements/Player/default_player_stats.tres")
var stats

var player_direction: String = "right"
var look_up_down: String = "forward"
var weapon
var get_damage_timer: float = 0.0

var anim_player: AnimationPlayer

var last_dash = 0.0

var subject

func _ready() -> void:
	# добавляем игрока в глобальную группу
	add_to_group('player')
	
	# создаем копию статов
	stats = player_stats.duplicate()
	
	# передаем эффект менеджеру игрока
	if effect_manager:
		effect_manager.player = self
	
	# загрузка интерфейса
	await get_tree().process_frame
	if hud:
		hud.setup_bar(stats.max_health, stats.max_mana)
		
		# ПОДКЛЮЧАЕМ СИГНАЛЫ РЕСУРСА К HUD:
		stats.health_changed.connect(func(cur, _max_v): hud.update_hp_bar(cur))
		stats.mana_changed.connect(func(cur, _max_v): hud.update_mp_bar(cur))

func _process(delta: float):	
	# взаимодействие с интерактивными предметами
	if subject:
		if Input.is_action_just_pressed("interact"):
			state_machine.change_state(state_machine.current_state, "Interactable", {"subject": subject})
	
	# поворачиваем спрайт игрока в зависимости от его направления
	animation_sprites.flip_h = (player_direction == 'left')

	# задаем направление взгляда игрока для атак
	if Input.is_action_pressed("look_up"):
		look_up_down = "up"
	elif Input.is_action_pressed("look_down"):
		look_up_down = "down"
	else:
		look_up_down = "forward"
	
	# кулдаун рывков
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	# изменение интерфейса
	if hud:
		hud.update_static_labels(stats.max_health, stats.max_mana, stats.crit_rate, stats.crit_multiplier, stats.damage_bonus)

	# регенерация ресурсов
	if stats.current_mana < stats.max_mana:
		stats.current_mana += stats.mana_regen * delta
		
	if stats.current_health < stats.max_health:
		stats.current_health += stats.health_regen * delta
						
	# уменьшаем таймер неуязвимости
	if get_damage_timer > 0:	
		get_damage_timer -= delta
		
# получение игроком урона
func take_player_damage(shake_intencity, shake_duration, amount: int, enemy_position: Vector2 = Vector2.ZERO) -> void:
	if get_damage_timer <= 0:
		stats.current_health -= amount
		get_damage_timer = stats.get_damage_cooldown
		
		if hud:
			hud.update_hp_bar(stats.current_health)
			
		if camera and camera.has_method("apply_shake"):
			camera.apply_shake(shake_intencity, shake_duration)
			
		# Отправляем параметры отбрасывания в StateMachine
		var push_direction = sign(global_position.x - enemy_position.x)
		if push_direction == 0: push_direction = 1
		
		var kb_velocity = Vector2(push_direction * 450.0, -150.0)
		
		# Переключаем автомат в состояние Knockback через менеджер
		if state_machine:
			state_machine.change_state(state_machine.current_state, "Knockback", {"velocity": kb_velocity})
			
# откидывание игрока его же атаками (возможно уберу это)
func self_knockback(push_force: float, attack_pos: Vector2) -> void:
	var push_direction = (global_position - attack_pos).normalized()
	var kb_velocity = Vector2.ZERO
	
	if push_direction.y < -0.3:
		kb_velocity.y = push_direction.y * (push_force * 1.3)
		kb_velocity.x = push_direction.x * (push_force * 5)
	else:
		kb_velocity = push_direction * (push_force * 2)
		
	if state_machine:
			state_machine.change_state(state_machine.current_state, "Knockback", {"velocity": kb_velocity})
			
# подсчет урона который нанес игрок
func calculate_damage(base_damage: float) -> Dictionary:
	# проверка на бонусы урона
	var damage_bonus = stats.get_damage_bonus()
	var modified_base: float = base_damage * (1.0 + (damage_bonus / 100.0))
	
	var final_damage: float = modified_base
	var is_crit: bool = false
	var roll = randf_range(0.0, 100.0)
	
	# расчет будет ли удар критом и сколько будет множитель
	if roll <= stats.crit_rate:
		final_damage = modified_base * stats.crit_multiplier
		is_crit = true
	
	# округление до целого числа
	var final_damage_int: int = roundi(final_damage)
	
	# и возвращаем итоговый урон
	return {"damage": final_damage_int, "is_crit": is_crit}

#  отображение кнопки взаимодействия с интерактивными предметами 
func _on_interact_area_entered(area: Area2D) -> void:
	if area is Interactable:
		area.show_hide_label()
		subject = area
		
# скрытие кнопки взаимдействия с интерактивными предметами
func _on_interact_area_exited(area: Area2D) -> void:
	if area is Interactable:
		area.show_hide_label()
		subject = null
