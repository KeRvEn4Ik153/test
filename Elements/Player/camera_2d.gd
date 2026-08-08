extends Camera2D

var shake_intensity: float = 0.0
var shake_duration: float = 0.0
var initial_intensity: float = 0.0
var is_decaying: bool = true # Флаг: затухает ли тряска

@export var look_offset_distance: float = 150.0 # Дистанция смещения в пикселях
@export var shift_speed: float = 5.0  
@export var look_delay: float = 0.5

var target_offset_y: float = 0.0
var holding_time: float = 0.0

@onready var state = $"../StateMachine"
@onready var player = get_parent()

func _physics_process(delta: float) -> void:
	
	# если игрок в состоянии idle то он может смотреть вверх и вниз
	if state.current_state == state.states["idle"]:
		if player.is_on_floor() and player.velocity.x == 0:
			if Input.is_action_pressed("look_up"):
				holding_time += delta
				if holding_time >= look_delay:
					target_offset_y = -look_offset_distance
			elif Input.is_action_pressed("look_down"):
				holding_time += delta
				if holding_time >= look_delay:
					target_offset_y = look_offset_distance
			else:
				holding_time = 0.0
				target_offset_y = 0.0
	else:
		holding_time = 0.0
		target_offset_y = 0.0

	# возвращаем камеру на место
	var current_look_offset = move_toward(offset.y, target_offset_y, shift_speed * delta * 100)

	if shake_duration > 0.0:
		shake_duration -= delta
		
		var current_intensity = shake_intensity
		# если тряска должна затухать со временем то уменьшаем тряску 
		if is_decaying:
			current_intensity = lerp(0.0, initial_intensity, shake_duration)
		
		var shake_x = randf_range(-current_intensity, current_intensity)
		var shake_y = randf_range(-current_intensity, current_intensity)
		
		offset = Vector2(shake_x, current_look_offset + shake_y)
	else:
		shake_intensity = 0.0
		initial_intensity = 0.0
		
		offset.x = move_toward(offset.x, 0.0, shift_speed * delta * 100)
		offset.y = current_look_offset

# функция для активирования тряски камеры
func apply_shake(intensity: float, duration: float, decay: bool = true) -> void:
	is_decaying = decay
	# Выбираем максимальную силу, если тряска уже идет
	shake_intensity = max(shake_intensity, intensity)
	initial_intensity = shake_intensity
	shake_duration = duration
