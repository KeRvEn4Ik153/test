extends EnemyBase

@onready var animation: AnimationPlayer = $AnimationPlayer

var jump_timer: float = 0.0

# логика потрулирования
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
	
# логика преследования
func _chase_logic(delta: float) -> void:
	if player_node:
		if not is_player_in_front():
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

# переопределяем функцию получения урона для новой механики
func take_damage(amount: int, knockback_power: float, attacker_position: Vector2 = Vector2.ZERO) -> void:
	if not is_player_in_front() and parry_player():
		_flip_enemy() 
		GameManager.hit_stop(0.08)
		return
		
	super.take_damage(amount, knockback_power, attacker_position)

# переопределяем функцию что бы враг не реагировал на игрока если он его видит
func _chek_line_of_sight():
	if player_node:
		return
	
	if current_state == State.CHASE:
		current_state = State.PATROL

# функция для парирования атаки игрока
func parry_player():
	player_node.take_player_damage(shake_intensity, shake_duration, 0, global_position)
	current_state = State.CHASE
	return true
