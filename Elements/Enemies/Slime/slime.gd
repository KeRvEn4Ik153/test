extends EnemyBase

@onready var animation: AnimationPlayer = $AnimationPlayer

var jump_timer: float = 0.0

func _patrol_logic(delta: float) -> void:
	jump_timer -= delta
	
	if jump_timer <= 0 and is_on_floor():
		animation.stop()
		animation.play('jump')
		velocity.y = enemy_stats.unic_stats["jump_force"]
		velocity.x = direction * enemy_stats.speed
		jump_timer = enemy_stats.unic_stats["jump_cooldown"]
	elif is_on_floor():
		
		velocity.x = move_toward(velocity.x, 0, enemy_stats.speed * 4 * delta)
		
	# Если врезался в стену во время прыжка — меняем направление
	if wall_detector.is_colliding():
		_flip_enemy()

	if not floor_detector.is_colliding():
		_flip_enemy()

# ЛОГИКА ПОГОНИ (Прыжки строго в сторону игрока)
func _chase_logic(delta: float) -> void:
	if player_node and is_player_in_area:
		var direction_to_player = sign(player_node.global_position.x - global_position.x)
		if direction_to_player != 0 and direction_to_player != direction:
			_flip_enemy()
		
		jump_timer -= delta
	
		if jump_timer <= 0 and is_on_floor():
			animation.stop()
			animation.play('jump')
			velocity.y = enemy_stats.unic_stats["jump_force"] - 50.0
			velocity.x = direction * enemy_stats.speed * 1.2
			jump_timer = enemy_stats.unic_stats["jump_cooldown"] - 0.5
		elif is_on_floor():
			velocity.x = move_toward(velocity.x, 0, enemy_stats.speed * 4 * delta)
		
		if is_on_floor() and not floor_detector.is_colliding():
			velocity.x = 0
