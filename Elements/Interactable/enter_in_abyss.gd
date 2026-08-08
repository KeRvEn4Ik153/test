extends Interactable

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pivot: Node2D = $Pivot

var next_scene_path = "res://Game/WorldScenes/main_scene.tscn"
var loading_screen_path = "res://Game/MenuScenes/loading_screen.tscn"

var is_playing: bool = false

func interact(player: CharacterBody2D):
	if is_playing:
		return
	is_playing = true
	
	show_hide_label()

	animation_player.animation_finished.connect(_on_animation_finished)

	pivot.global_position = player.global_position

	player.get_parent().call_deferred("remove_child", player)
	pivot.call_deferred("add_child", player)

	player.call_deferred("set_position", Vector2.ZERO)

	animation_player.play("EnterInAbyss")

func _on_animation_finished(anim_name: StringName):
	if anim_name == "EnterInAbyss":
		load_to_next_level()
		
func load_to_next_level():
	if next_scene_path:
		GlobalData.target_scene = next_scene_path
		get_tree().change_scene_to_file(loading_screen_path)
