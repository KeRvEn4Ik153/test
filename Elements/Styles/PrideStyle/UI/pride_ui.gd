extends Control
class_name PrideUI

@onready var stacksbar = $PanelContainer/StacksBar
@onready var stackslabel = $PanelContainer/StacksBar/StacksLabel

@export var max_value: int = 10

func _ready() -> void:
	if stacksbar:
		stacksbar.max_value = max_value

func update_stacks(stacks):
	if stacksbar:
		stacksbar.value = stacks
	if stackslabel:
		stackslabel.text = str(int(stacks)) + " / " + str(int(stacksbar.max_value))
