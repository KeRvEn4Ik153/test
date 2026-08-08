extends Control

@onready var progress_bar: ProgressBar = $ProgressBar

var scene_path: String
var progress: Array = []

func _ready() -> void:
	scene_path = GlobalData.target_scene
	
	if scene_path == "":
		print('Error: path is empty')
		return
		
	ResourceLoader.load_threaded_request(scene_path)
	
func _process(_delta: float) -> void:
	var status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_bar.value = progress[0] * 100
		ResourceLoader.THREAD_LOAD_LOADED:
			progress_bar.value = 100
			var new_scene = ResourceLoader.load_threaded_get(scene_path)
			get_tree().change_scene_to_packed(new_scene)
			
		ResourceLoader.THREAD_LOAD_FAILED:
			print('Error: failed load scene')	
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			print('Error: path is not true')
