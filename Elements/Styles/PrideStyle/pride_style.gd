extends StyleData
	
var bow_stacks = 0
	
var camera_tween: Tween
	
const BASE_ZOOM = Vector2(1.0, 1.0)
const ZOOM_LEVELS = [
	Vector2(0.95, 0.95), # 1-й клик
	Vector2(0.88, 0.88), # 2-й клик
	Vector2(0.80, 0.80)  # 3-й клик (перед выстрелом)
]

# переменые для новой механики
var will: int = 0
var life_time_of_stack: float = 10.0
var is_crit_rate_buff_active: bool = false
var crit_rate_buff: float = 10.0

func _process(delta: float) -> void:
	super._process(delta)

	UI.update_anim_lanel(animation_hitbox.current_animation)

	life_time_of_stack -= delta
	if life_time_of_stack <= 0:
		managment_stacks(false, false)

func attack1():
	attack_direction()
	return true
	
func attack2():
	attack_direction()
	return true

func attack3():
	attack_direction()
	return true

# переопределяем функцию с базового класса для добавления новой механики
func what_to_do_with_attack(cast_result):
	# ЕСЛИ ИГРОК УЖЕ АТАКУЕТ: записываем комбо в буфер наперед	
				if player_node.state_machine.current_state.name == "Attack":
					if player_node.state_of_attack == "perfect_window":
						player_node.buffered_attack = {
							"anim_player": cast_result["anim_player"],
							"anim_name": cast_result["anim_name"],
							"mana_cost": cast_result["mana_cost"],
							"can_movement": cast_result["can_movement"]
						}
						managment_stacks(true, false)
						life_time_of_stack = 10.0
						return
					if cast_result["change_attack"]:
						player_node.change_animation = {
							"anim_player": cast_result["anim_player"],
							"anim_name": cast_result["anim_name"],
							"mana_cost": cast_result["mana_cost"],
							"can_movement": cast_result["can_movement"]
						}
						return
					if not cast_result["change_attack"]:
						player_node.buffered_attack = {
							"anim_player": cast_result["anim_player"],
							"anim_name": cast_result["anim_name"],
							"mana_cost": cast_result["mana_cost"],
							"can_movement": cast_result["can_movement"],
						}
						managment_stacks(false, true)
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

const ATTACK_POSITION = {
	"right": Vector2(30, 0),
	"left": Vector2(-30, 0),
	"up": Vector2(0, -30),
	"down": Vector2(0, 30)
}

func attack_direction():
	var direction
	
	if player_node.look_up_down == "forward":
		direction = player_node.player_direction
	else: 
		direction = player_node.look_up_down
		
	area.position = ATTACK_POSITION[direction]

func managment_stacks(plus: bool, clean: bool):
	if clean:
		player_node.stats.stacks -= will
		will = 0
		UI.update_stacks(will)	
		if is_crit_rate_buff_active:
			player_node.stats.crit_rate -= crit_rate_buff
			is_crit_rate_buff_active = false
		return
	if plus:
		if will < 10:
			will += 1
			player_node.stats.stacks += 1
			UI.update_stacks(will)
			if not is_crit_rate_buff_active and will >= 5:
				player_node.stats.crit_rate += crit_rate_buff
				is_crit_rate_buff_active = true
	if not plus:
		if will > 0:
			will -= 1
			player_node.stats.stacks -= 1
			UI.update_stacks(will)
			if is_crit_rate_buff_active and will < 5:
				player_node.stats.crit_rate -= crit_rate_buff
				is_crit_rate_buff_active = false
	player_node.stats.get_damage_bonus()

#func unic_burn_effect():
	#var new_effect = UnicBurnEffect.new(10.0, 5, 20)
	#player_node.effect_manager.add_effect(new_effect)
	#return true

#func bow_charge():
	#bow_stacks = 0
	#camera_shake(0.2, 999999.0, false)
	#return true

#func bow_shot():
	#if attack_resource.state_of_attack == "perfect_window_for_shot":
		#managment_stacks(true, false)
	#bow_stacks += 1
	#if bow_stacks == 1:
		#camera_shake(0.4, 999999.0, false)
	#if bow_stacks == 2:
		#camera_shake(0.6, 999999.0, false)

	#var next_zoom = ZOOM_LEVELS[bow_stacks - 1]
	#animate_camera_zoom(next_zoom, 0.10) 
	
	#if bow_stacks == 3:
		#bow_stacks = 0
		#animate_camera_zoom(BASE_ZOOM, 0.4) 
		#return true
	#return false

# функция отдаления камеры
func animate_camera_zoom(target_zoom: Vector2, duration: float = 0.2) -> void:
	# Если предыдущая анимация камеры еще идет — убиваем её, чтобы не было конфликтов
	if camera_tween and camera_tween.is_valid():
		camera_tween.kill()
		
	# Создаем новый Tween
	camera_tween = create_tween()
	
	# Плавно меняем свойство zoom у камеры. 
	# TRANS_SINE и EASE_OUT сделают движение мягким в конце.
	camera_tween.tween_property(player_camera, "zoom", target_zoom, duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)	
