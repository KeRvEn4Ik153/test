extends Node

@export var initial_state: Player_State

var current_state: Player_State
var states: Dictionary = {}

func _ready() -> void:
	await owner.ready
	
	# получение всех состояний игрока
	for child in get_children():
		if child is Player_State:
			states[child.name.to_lower()] = child
			child.character = owner as Player
	
	# начальное состояние игрока
	if initial_state:
		initial_state.enter()
		current_state = initial_state

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

# функция для смены состояния
func change_state(source_state: Player_State, new_state_name: String, data: Dictionary = {}) -> void:
	if source_state != current_state:
		return
		
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
		
	if current_state:
		current_state.exit()
		
	new_state.enter(data)
	current_state = new_state
