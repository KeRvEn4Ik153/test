extends CharacterBody2D
class_name Player

var dash_cooldown_timer: float = 0.0

@export var available_style: ItemData
@export var combo_window: float = 0.4

@onready var hud: Control = $"../CanvasLayer/HUD"
@onready var current_slot: Node2D = $Slot1
@onready var camera: Camera2D = $Camera2D
@onready var animation_sprites: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: Node = $StateMachine
@onready var effect_manager: Node2D = $EffectManager

@onready var player_stats: DefaultPlayerStatsData = load("res://Elements/Player/default_player_stats.tres")
var stats

@onready var UI_container = $ItemUI

var player_direction: String = "right"
var look_up_down: String = "forward"
var weapon
var get_damage_timer: float = 0.0

var input_button: String = "" 	
var combo_timer: Timer
var trigger_actions = ["left_skill", "right_skill", "melee_attack", "range_attack"]
var local_history = []

var anim_player: AnimationPlayer

var cast_result
var style: Resource

var last_dash = 0.0

var subject

var buffered_attack: Dictionary = {}
var change_animation: Dictionary = {}

var state_of_attack: String = ""

func _ready() -> void:
	# создаем копию статов
	stats = player_stats.duplicate()
	
	# передаем эффект менеджеру игрока
	if effect_manager:
		effect_manager.player = self
	
	# подгатавливаем таймер для прожатия комбо
	combo_timer = Timer.new()
	add_child(combo_timer)
	combo_timer.wait_time = combo_window
	combo_timer.one_shot = true
	combo_timer.timeout.connect(func(): local_history.clear())
	
	
	# загрузка интерфейса
	await get_tree().process_frame
	if hud:
		hud.setup_bar(stats.max_health, stats.max_mana)
		
		# ПОДКЛЮЧАЕМ СИГНАЛЫ РЕСУРСА К HUD:
		stats.health_changed.connect(func(cur, _max_v): hud.update_hp_bar(cur))
		stats.mana_changed.connect(func(cur, _max_v): hud.update_mp_bar(cur))
		
	# добавляем игрока в глобальную группу
	add_to_group('player')

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
		hud.update_combo_label(local_history)
		hud.update_static_labels(stats.max_health, stats.max_mana, stats.crit_rate, stats.crit_multiplier, stats.damage_bonus)

	# регенерация ресурсов
	if stats.current_mana < stats.max_mana:
		stats.current_mana += stats.mana_regen * delta
		
	if stats.current_health < stats.max_health:
		stats.current_health += stats.health_regen * delta
				
	# использование стилей
	if trigger_actions.any(func(action): return Input.is_action_just_pressed(action)):
		if weapon and weapon.has_method("try_cast") and state_machine.current_state != state_machine.states.get("knockback"):
			cast_result = weapon.try_cast(input_button, stats.current_mana, global_position, get_global_mouse_position())
			
			if cast_result and cast_result["is_combo"]:
				local_history.clear()
				combo_timer.stop()

				if weapon.has_method("what_to_do_with_attack"):
					weapon.what_to_do_with_attack(cast_result)
						
	# уменьшаем таймер неуязвимости
	if get_damage_timer > 0:	
		get_damage_timer -= delta

# добавление нажатых кнопок для комбо и интерфейса
func _input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo():
		var combo_actions = ["range_attack", "melee_attack", "left_skill", "right_skill"]
		for action in combo_actions:
			if event.is_action_pressed(action):
				_add_to_history(action)
				_add_to_local_history(action)
				break
				
# добавление в историю нажатий
func _add_to_history(action_name: String) -> void:
	input_button = action_name 
	combo_timer.start()
	
# добавление в историю нажатий для интерфейса
func _add_to_local_history(action_name: String) -> void:
	if action_name == "range_attack":
		local_history.append(tr("KEY_RANGE_ATTACK"))
	if action_name == "melee_attack":
		local_history.append(tr("KEY_MELEE_ATTACK"))
	if action_name == "left_skill":
		local_history.append(tr("KEY_LEFT_SKILL"))
	if action_name == "right_skill":
		local_history.append(tr("KEY_RIGHT_SKILL"))
		
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
	
# добавление стилей в слоты (надо сделать всего один слот под стиль, то есть убрать хотбар)
func equip_slot():
	if current_slot.get_child_count() == 0:
		if available_style.style_scene:
			var magic = available_style.style_scene.instantiate()
			current_slot.add_child(magic)
	if current_slot.get_child_count() > 0:
		return current_slot.get_child(0)
		
# заполнение слотов хотбара
func fill_slot(path_item):
	style = load(path_item)
	available_style = null
	available_style = style
	weapon = equip_slot()

	var item_ui = weapon.UI_scene.instantiate()
	UI_container.add_child(item_ui)

	weapon.UI = item_ui

	if hud:
		hud.setup_style_tree()

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
