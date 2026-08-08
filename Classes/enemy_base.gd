extends CharacterBody2D
class_name EnemyBase

enum State {STUNNED, KNOCKBACK, PATROL, CHASE}
var current_state: State = State.PATROL

@export var enemy_stats: EnemyStats

@export var shake_intencity: float = 0.0
@export var shake_duration: float = 0.2

@export var damage_indicator_scene: PackedScene = preload("res://Elements/Something/damage_label.tscn")

@onready var sprite = $AnimatedSprite2D
@onready var line_of_sight: RayCast2D = $LineOfSight
@onready var wall_detector: RayCast2D = $WallDetector
@onready var floor_detector: RayCast2D = $FloorDetector
@onready var enemy_effect_manager: Node2D = $EffectManager

var is_player_touching_body: bool = false
var player_node: Node2D = null
var effect_timer: float = 0.0
var knockback_velocity: Vector2 = Vector2.ZERO
var direction = 1
var is_player_in_area = false

func _ready() -> void:
	enemy_stats.current_health = enemy_stats.max_health
	enemy_stats = enemy_stats.duplicate()
	
	if enemy_effect_manager:
		enemy_effect_manager.enemy = self
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += enemy_stats.gravity * delta
	if current_state != State.STUNNED and current_state != State.KNOCKBACK:
		_chek_line_of_sight()
	
	match current_state:
		State.STUNNED:
			_sttuned_logic(delta)
		State.KNOCKBACK:
			_knockback_logic(delta)
		State.PATROL:
			_patrol_logic(delta)
		State.CHASE:
			_chase_logic(delta)
			
	move_and_slide()
			
	_process_touch_damage_tick()
			
func _process_touch_damage_tick() -> void:
	if is_player_touching_body:
		if player_node and player_node.has_method("take_player_damage"):
			# Передаем урон и текущую глобальную позицию врага для расчета отброса игрока
			player_node.take_player_damage(shake_intencity, shake_duration, enemy_stats.damage, global_position)
			
func _sttuned_logic(delta: float) -> void:
	velocity.x = 0
	effect_timer -= delta
	if effect_timer <= 0:
		_recover_from_effect()
	
func _knockback_logic(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 1500 * delta)
	
	effect_timer -= delta
	if effect_timer <= 0:
		_recover_from_effect()

func _patrol_logic(_delta: float) -> void:
	pass

func _chase_logic(_delta: float) -> void:
	pass

func _recover_from_effect():
	sprite.modulate = Color(1, 1, 1)
	current_state = State.CHASE
	
func take_damage(amount: int, time_of_stun: float, knockback_power: float, element: String, damage_type: String = "stun", attacker_position: Vector2 = Vector2.ZERO) -> void:
	if not player_node:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player_node = players[0] 
			is_player_in_area = true
	
	var CD = player_node.calculate_damage(amount, enemy_stats.resists, element)
	enemy_stats.current_health -= CD["damage"]
	spawn_damage_indicator(CD["damage"], CD["is_crit"])
	
	if enemy_stats.current_health <= 0:
		queue_free()
		return
		
	var attacker_dir_side = sign(attacker_position.x - global_position.x)
	if attacker_dir_side != 0 and attacker_dir_side != direction:
		_flip_enemy() 
		
	match damage_type:
		"stun":
			current_state = State.STUNNED
			effect_timer = time_of_stun
			sprite.modulate = Color(0.5, 0.5, 1)
			
		"knockback":
			current_state = State.KNOCKBACK
			effect_timer = time_of_stun
			sprite.modulate = Color(1, 0.5, 0.5)
			
			var knockback_dir = sign(global_position.x - attacker_position.x)
			if knockback_dir == 0:
				knockback_dir = -direction 
				
			velocity.x = knockback_dir * knockback_power	
	
func spawn_damage_indicator(amount: int, is_crit: bool):
	if damage_indicator_scene:
		var indicator = damage_indicator_scene.instantiate() as Label
		if not is_crit:
			indicator.text = str(amount)
		else: 
			indicator.text = str(amount) + "!!"
		indicator.global_position = global_position + Vector2(-20, -30)
		get_tree().current_scene.add_child(indicator)

func _chek_line_of_sight():
	if is_player_in_area and player_node:
		var player_direction_side = sign(player_node.global_position.x - global_position.x)

		if current_state == State.PATROL:
			if player_direction_side != 0 and player_direction_side != direction:
				return 

		line_of_sight.target_position = player_node.global_position - global_position
		
		if line_of_sight.is_colliding():
			var collider = line_of_sight.get_collider()
			if collider.is_in_group("player"):
				current_state = State.CHASE
				return
				
	if current_state == State.CHASE:
		current_state = State.PATROL
	
func _flip_enemy():
	direction *= -1
	sprite.flip_h = (direction == -1)
	
	wall_detector.target_position *= -1
	floor_detector.position.x *= -1

func _on_enemy_body_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_node = body
		is_player_touching_body = true

func _on_enemy_body_area_body_exited(body: Node2D) -> void:
	if body == player_node:
		is_player_touching_body = false
		
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_node = body
		is_player_in_area = true
		
func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player_node:
		player_node = null
		is_player_in_area = false
