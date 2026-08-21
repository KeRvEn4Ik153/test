extends Node2D
class_name StyleManager

@onready var current_style: Node2D = $"../StyleSlot"
@onready var state_machine: Node = $"../StateMachine"

@onready var UI_container = $"../ItemUI"
@onready var hud: Control = $"../../CanvasLayer/HUD"

@onready var player: CharacterBody2D = $".."

@export var available_style: ItemData
@export var combo_window: float = 0.4

var input_button: String = "" 	
var combo_timer: Timer
var trigger_actions = ["left_skill", "right_skill", "melee_attack", "range_attack"]
var local_history = []

var cast_result
var style: Resource
var style_path: String

var buffered_attack: Dictionary = {}
var change_animation: Dictionary = {}
var state_of_attack: String = ""

var weapon

func _ready() -> void:
	# подгатавливаем таймер для прожатия комбо
	combo_timer = Timer.new()
	add_child(combo_timer)
	combo_timer.wait_time = combo_window
	combo_timer.one_shot = true
	combo_timer.timeout.connect(func(): local_history.clear())

func _process(_delta: float) -> void:
	if hud:
		hud.update_combo_label(local_history)

	if trigger_actions.any(func(action): return Input.is_action_just_pressed(action)):
		if weapon and weapon.has_method("try_cast") and state_machine.current_state != state_machine.states.get("knockback"):
			cast_result = weapon.try_cast(input_button, player.stats.current_mana, global_position, get_global_mouse_position())
						
			if cast_result and cast_result["is_combo"]:
				local_history.clear()
				combo_timer.stop()

				if weapon.has_method("what_to_do_with_attack"):
					weapon.what_to_do_with_attack(cast_result)

# добавление нажатых кнопок для комбо и интерфейса
func _input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo():
		var combo_actions = ["range_attack", "melee_attack", "left_skill", "right_skill"]
		for action in combo_actions:
			if event.is_action_pressed(action):
				# использование стилей
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

# добавление стилей в слоты (надо сделать всего один слот под стиль, то есть убрать хотбар)
func equip_slot():
	if current_style.get_child_count() == 0:
		if available_style.style_scene:
			var create_style = available_style.style_scene.instantiate()
			current_style.add_child(create_style)
	if current_style.get_child_count() > 0:
		return current_style.get_child(0)
		
# заполнение слотов хотбара
func fill_slot(path_item):
	style = load(path_item)
	style_path = path_item
	available_style = null
	available_style = style
	weapon = equip_slot()

	var item_ui = weapon.UI_scene.instantiate()
	UI_container.add_child(item_ui)

	weapon.UI = item_ui

	if hud:
		hud.setup_style_tree()
