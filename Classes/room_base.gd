extends Node2D
class_name RoomBase

# Размеры комнаты в тайлах (нужно для правильной стыковки комнат)
@export var room_width: int = 30
@export var room_height: int = 17

# Маркеры внутри этой конкретной комнаты
@onready var enemies_spawn: Node2D = $EnemiesSpawn

# Сюда генератор передаст сцену врага
func spawn_enemies(enemy_scene: PackedScene) -> void:
	if not enemy_scene or not enemies_spawn: return
	
	for marker in enemies_spawn.get_children():
		if marker is Marker2D:
			var enemy = enemy_scene.instantiate()
			enemy.global_position = marker.global_position
			add_child(enemy)
