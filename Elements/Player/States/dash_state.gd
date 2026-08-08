extends Player_State

var dash_timer: float = 0.0
var dash_direction: float = 1.0

func enter(_data: Dictionary = {}) -> void:
	# получаем время рывка
	dash_timer = character.stats.dash_duration
	CR.color = Color(0.0, 1.0, 0.0, 1.0)
	
	# проверяем, куда жмет игрок. если никуда не жмет, рывок идет в сторону взгляда
	var input_dir = Input.get_axis("ui_left", "ui_right")
	if input_dir != 0:
		dash_direction = sign(input_dir)
	else:
		dash_direction = -1.0 if character.animation_sprites.flip_h else 1.0
		
	character.animation_sprites.play("walk") 
	
	# делаем игрока неуязвимым на время рывка
	character.get_damage_timer = character.stats.dash_duration

func physics_update(delta: float) -> void:
	# во время рывка гравитации нет для игрока
	character.velocity.x = dash_direction * character.stats.dash_speed
	character.velocity.y = 0 
	
	character.move_and_slide()
	
	dash_timer -= delta
	if dash_timer <= 0:
		# когда рывок закончился, проверяем где мы находимся
		if character.is_on_floor():
			get_parent().change_state(self, "Idle")
		else:
			get_parent().change_state(self, "Jump")
