extends SpellBase

@export var aoe_radius: float = 80.0

func _on_body_entered(_body: Node2D) -> void:
		explode_aoe()
		
		spawn_explosion()
		
		destroy_spell()

func explode_aoe() -> void:
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = aoe_radius
	
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = circle_shape
	query.transform = global_transform # Центр взрыва — там, где сейчас пуля
	
	query.collision_mask = _get_custom_mask([2, 3])
	
	var space_state = get_world_2d().direct_space_state
	var results = space_state.intersect_shape(query)
	
	for result in results:
		var hit_object = result["collider"]
		
		if hit_object and hit_object.has_method("take_damage"):
			hit_object.take_damage(damage, time_of_stun, knockback_power, damage_type, global_position)
			
		if hit_object.is_in_group('player') and hit_object.has_method('self_knockback'): 
			hit_object.self_knockback(280.0 ,global_position)

func _get_custom_mask(layers: Array[int]) -> int:
	var mask = 0
	for layer in layers:
		mask |= (1 << (layer - 1))
	return mask
