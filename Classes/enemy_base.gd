extends CharacterBody2D
class_name EnemyBase

enum State {KNOCKBACK, PATROL, CHASE}
var current_state: State = State.PATROL

@export var enemy_stats: EnemyStats

@export var shake_intensity: float = 0.0
@export var shake_duration: float = 0.2

@export var damage_indicator_scene: PackedScene = preload("res://Elements/Something/damage_label.tscn")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# детектор для проверки находится ли игрок в непосредственой видимости для врага
@onready var line_of_sight: RayCast2D = $LineOfSight

@onready var wall_detector: RayCast2D = $WallDetector # детектор для стен 
@onready var floor_detector: RayCast2D = $FloorDetector # детектор для пола
@onready var enemy_effect_manager: Node2D = $EffectManager

var is_player_touching_body: bool = false
var player_node: Node2D = null
@export var knockback_timer: float = 0.3
var direction: int = 1
	
func _ready() -> void:
	enemy_stats = enemy_stats.duplicate()
	enemy_stats.current_health = enemy_stats.max_health
	
	if enemy_effect_manager:
		enemy_effect_manager.enemy = self
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += enemy_stats.gravity * delta
	if current_state != State.KNOCKBACK:
		_chek_line_of_sight()
	
	match current_state:
		State.KNOCKBACK:
			_knockback_logic(delta)
		State.PATROL:
			_patrol_logic(delta)
		State.CHASE:
			_chase_logic(delta)
			
	move_and_slide()
			
	_process_touch_damage_tick()

# если игрок касаеться врага то получает урон
func _process_touch_damage_tick() -> void:
	if is_player_touching_body:
		if player_node and player_node.has_method("take_player_damage"):
			# Передаем урон и текущую глобальную позицию врага для расчета отброса игрока
			player_node.take_player_damage(shake_intensity, shake_duration, enemy_stats.damage, global_position)	

# логика состояния отбрасывания
func _knockback_logic(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 1500 * delta)
	
	knockback_timer -= delta
	if knockback_timer <= 0:
		_recover_from_effect()

# будущая логика патрулирования
func _patrol_logic(_delta: float) -> void:
	pass

# будущая логика преследования то есть когда враг начанает сражаться с игроком
func _chase_logic(_delta: float) -> void:
	pass

# функция востоновления после какого либо эффекта
func _recover_from_effect():
	sprite.modulate = Color(1, 1, 1)
	current_state = State.CHASE
	
# функция получения урона врага
func take_damage(amount: int, knockback_power: float, attacker_position: Vector2 = Vector2.ZERO) -> void:
	if not player_node:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player_node = players[0] 
	
	var CD = player_node.calculate_damage(amount)
	enemy_stats.current_health -= CD["damage"]
	spawn_damage_indicator(CD["damage"], CD["is_crit"])
	
	if check_death():
		return
		
	if not is_player_in_front():
		_flip_enemy() 
	
	current_state = State.KNOCKBACK
	sprite.modulate = Color(1, 0.5, 0.5)
			
	var knockback_dir = sign(global_position.x - attacker_position.x)
	if knockback_dir == 0:
		knockback_dir = -direction 
				
	velocity.x = knockback_dir * knockback_power	

# проверка в какой стороне находится игрок относительно врага
func get_direction_to_player() -> int:
	if not player_node:
		return 0
	
	return sign(player_node.global_position.x - global_position.x)

# а тут явная проверка находится ли игрок перед врагом если да то true если нет то false
func is_player_in_front() -> bool:
	var player_direction := get_direction_to_player()
	return player_direction != 0 and player_direction == direction

# проверка должен ли умереть враг
func check_death() -> bool:
	if enemy_stats.current_health <= 0:
		queue_free()
		return true

	return false

# спавн числа урона
func spawn_damage_indicator(amount: int, is_crit: bool):
	if damage_indicator_scene:
		var indicator = damage_indicator_scene.instantiate() as Label
		if not is_crit:
			indicator.text = str(amount)
		else: 
			indicator.text = str(amount) + "!!"
		indicator.global_position = global_position + Vector2(-20, -30)
		get_tree().current_scene.add_child(indicator)

# проверка находится ли игрок в поле зрения врага если да то переходим в состояние преследования
func _chek_line_of_sight():
	if player_node:

		if current_state == State.PATROL:
			if not is_player_in_front():
				return 

		line_of_sight.target_position = player_node.global_position - global_position
		
		if line_of_sight.is_colliding():
			var collider = line_of_sight.get_collider()
			if collider.is_in_group("player"):
				current_state = State.CHASE
				return
				
	if current_state == State.CHASE:
		current_state = State.PATROL
	
# переворот врага вместе со спрайтом и его датчиками
func _flip_enemy():
	direction *= -1
	sprite.flip_h = (direction == -1)
	
	wall_detector.target_position *= -1
	floor_detector.position.x *= -1

# проверка дотрагиваеться ли игрок врага
func _on_enemy_body_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_node = body
		is_player_touching_body = true

# когда игрок перестает дотрагиваться до врага
func _on_enemy_body_area_body_exited(body: Node2D) -> void:
	if body == player_node:
		is_player_touching_body = false
		
# проверка находится ли игрок в хитбоксе зрения врага
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_node = body

# когда игрок вышел из хитбокса зрения врага
func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player_node:
		player_node = null
