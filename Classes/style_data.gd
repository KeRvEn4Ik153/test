extends Node2D
class_name StyleData

@export var attack_resources: Array[AttackData] = []
var attack_resource: AttackData

@export var element_type: String = ""

@onready var animation_hitbox: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area: Area2D = $Area2D
@onready var hitbox: CollisionShape2D = $Area2D/CollisionShape2D

var player_node: Node2D = null
var manager: Node2D = null
var player_camera: Camera2D
var cooldowns = {}

var last_spawn_position: Vector2 = Vector2.ZERO
var last_target_position: Vector2 = Vector2.ZERO

var enemy_effect_manager = null
var inflict_effect = null

@export var UI_scene: PackedScene
var UI

func _ready() -> void:
	player_node = get_parent().get_parent()
	manager = player_node.get_node("EffectManager")
	player_camera = player_node.get_node("Camera2D")
	
	hitbox.disabled = true
	animated_sprite.visible = false

	if area:
		area.body_entered.connect(_on_area_2d_body_entered)

func _process(delta: float) -> void:
	if attack_resource:
		player_node.state_of_attack = attack_resource.state_of_attack
	for key in cooldowns:
		cooldowns[key] -= delta

# спавн эффектов атаки происходит в AnimationPlayer
func spawn_effect(effect: PackedScene) -> void:
	if effect:
		var new_effect = effect.instantiate()
		new_effect.global_position = global_position
		get_tree().current_scene.add_child(new_effect)

# большая функция для выполнения атаки
func try_cast(input_button: String, player_mana: float, spawn_position: Vector2, target_position: Vector2):
	last_spawn_position = spawn_position
	last_target_position = target_position
	
	# перебераем все ресурсы с подробностями об атаке
	for res in attack_resources:
		if not res: continue
		
		# выбираем нужный ресурс в зависимости от нажатой кнопки и прошлой анимацией
		if res.which_button_to_attack == input_button and (animation_hitbox.current_animation in res.after_which_attack or (len(res.after_which_attack) == 0 and animation_hitbox.current_animation != res.id)):
			
			var current_cooldown = cooldowns.get(res.id, 0.0)
			# проверка хватает ли у игрока маны 
			if player_mana >= res.mana_cost and current_cooldown <= 0:
				# тут проверка есть ли функция у атаки (функция должна называться как сама атака)
				if has_method(res.id):
					var result = call(res.id)
					if not result:
						return
				# переменая с нужным ресурсом для других функций
				attack_resource = res
				
				# проверка находится ли способность в кулдауне
				if res.cooldown > 0:
					cooldowns[res.id] = res.cooldown

				# возвращаем все что нужно 
				return {
					"is_combo": true, 
					"mana_cost": res.mana_cost,
					"anim_name": res.animation_name,
					"anim_player": animation_hitbox,
					"can_movement": res.can_movement,
					"change_attack": res.change_attack
				}
	# на всякий случай что бы не было вылетов и ошибок
	return {"is_combo": false, "mana_cost": 0.0}

# функция для проверки что делать с атакой
func what_to_do_with_attack(cast_result):
	# ЕСЛИ ИГРОК УЖЕ АТАКУЕТ: записываем комбо в буфер наперед	
				if player_node.state_machine.current_state.name == "Attack":
					if not cast_result["change_attack"]:
						player_node.buffered_attack = {
							"anim_player": cast_result["anim_player"],
							"anim_name": cast_result["anim_name"],
							"mana_cost": cast_result["mana_cost"],
							"can_movement": cast_result["can_movement"],
						}
						return
					if cast_result["change_attack"]:
						player_node.change_animation = {
							"anim_player": cast_result["anim_player"],
							"anim_name": cast_result["anim_name"],
							"mana_cost": cast_result["mana_cost"],
							"can_movement": cast_result["can_movement"]
						}
						return
				else:
							# ЕСЛИ ИГРОК НЕ АТАКУЕТ: выполняем комбо сразу
					if cast_result["mana_cost"]:
						player_node.stats.current_mana -= cast_result["mana_cost"]
									
					if cast_result.has("anim_name") and cast_result["anim_name"] != "":
						player_node.state_machine.change_state(player_node.state_machine.current_state, "Attack", {
							"anim_player": cast_result["anim_player"],
							"anim_name": cast_result["anim_name"],
							"can_movement": cast_result["can_movement"]
						})

# спавн прожектайлов с анимации
func spawn_object_from_animation():
	if attack_resource.projectile_scene:
		var spell = attack_resource["projectile_scene"].instantiate()
		spell.update_stats(attack_resource.damage,
				attack_resource.mana_cost,
				attack_resource.knockback_power,
				attack_resource.stun_time,
				attack_resource.type_damage,
				attack_resource.element_type)
		spell.global_position = last_spawn_position
		spell.look_at(last_target_position)
		get_tree().current_scene.add_child(spell)

# проверка коснулся ли хитбокс атаки врага
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		var attacker_pos = player_node.global_position if player_node else global_position
		# если атака должна накладывать эффект то накладываем
		if body.has_node("EffectManager"):
			enemy_effect_manager = body.get_node("EffectManager")
			if not inflict_effect == null:
				enemy_effect_manager.add_effect(inflict_effect)
			
		body.take_damage(attack_resource.damage, 
			attack_resource.stun_time, 
			attack_resource.knockback_power, 
			attack_resource.element_type, 
			attack_resource.type_damage, 
			attacker_pos)

# функция создания эффекта для AnimationPlayer
func inflicting_effect(effect, duration: float, effect_damage: float):
	inflict_effect = effect.new(duration, effect_damage)

# функция тряски камеры для AnimationPlayer
func camera_shake(shake_intencity: float, shake_duration: float, is_decaying: bool):
	if player_camera and player_camera.has_method("apply_shake"):
		player_camera.apply_shake(shake_intencity, shake_duration, is_decaying)

func change_attack_state(state: String):
	attack_resource.state_of_attack = state
