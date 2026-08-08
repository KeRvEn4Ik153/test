extends SpellBase

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage, time_of_stun, knockback_power, damage_type, global_position)
		if camera and camera.has_method("apply_shake"):
			camera.apply_shake(shake_intencity, shake_duration)
	else:
		destroy_spell()
	spawn_explosion()
