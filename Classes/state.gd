class_name Player_State
extends Node

# Ссылка на главного персонажа, передается из машины состояний
var character: Player
@onready var CR: ColorRect = $"../../ColorRect"

# Вызывается при переходе в это состояние
func enter(_data: Dictionary = {}) -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
