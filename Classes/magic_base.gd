extends Node2D
class_name MagicBase

@export var cooldown: float = 0.5
@export var mana_cost: float = 10.0
@export var spell_scene: PackedScene

var time_since_last_spell: float = 0.0

func _process(delta: float) -> void:
	time_since_last_spell += delta	

func try_cast(spawn_position: Vector2, target_position: Vector2, player_mana: float) -> bool:
	if time_since_last_spell < cooldown:
		return false
		
	if player_mana < mana_cost:
		return false
	
	cast_spell(spawn_position, target_position)
	
	time_since_last_spell = 0.0
	return true

func cast_spell(spawn_position: Vector2, target_position: Vector2) -> void:
	if spell_scene:
		var spell = spell_scene.instantiate()
		spell.global_position = spawn_position
		spell.look_at(target_position)
		get_tree().current_scene.add_child(spell)
