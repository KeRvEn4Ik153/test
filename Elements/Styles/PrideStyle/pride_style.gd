extends StyleData
	
var bow_stacks = 0
	
var camera_tween: Tween
	
const BASE_ZOOM = Vector2(1.0, 1.0)
const ZOOM_LEVELS = [
	Vector2(0.95, 0.95), # 1-й клик
	Vector2(0.88, 0.88), # 2-й клик
	Vector2(0.80, 0.80)  # 3-й клик (перед выстрелом)
]
	
func unic_burn_effect():
	var new_effect = UnicBurnEffect.new(10.0, 5, 20)
	player_node.effect_manager.add_effect(new_effect)
	return true

func bow_charge():
	bow_stacks = 0
	camera_shake(0.2, 999999.0, false)
	return true

func bow_shot():
	bow_stacks += 1
	if bow_stacks == 1:
		camera_shake(0.4, 999999.0, false)
	if bow_stacks == 2:
		camera_shake(0.6, 999999.0, false)

	var next_zoom = ZOOM_LEVELS[bow_stacks - 1]
	animate_camera_zoom(next_zoom, 0.10) 
	
	if bow_stacks == 3:
		bow_stacks = 0
		animate_camera_zoom(BASE_ZOOM, 0.4) 
		return true
	return false

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
