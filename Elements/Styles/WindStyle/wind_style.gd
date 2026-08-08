extends StyleData

func _ready():
	COMBO_LIST = {
		["range_attack"]: "cast_windball"
	}
	
func cast_windball(spawn_position: Vector2, target_position: Vector2, player_mana: float) -> void:
	var mana_cost: float = 20.0
	if player_mana >= mana_cost:
		if spell_scenes:
			var spell = spell_scenes[0].instantiate()
			spell.global_position = spawn_position
			spell.look_at(target_position)
			get_tree().current_scene.add_child(spell)
