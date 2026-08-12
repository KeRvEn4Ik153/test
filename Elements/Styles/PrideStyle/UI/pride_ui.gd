extends Control
class_name PrideUI

@onready var stacksbar = $PanelContainer/StacksBar
@onready var stackslabel = $PanelContainer/StacksBar/StacksLabel

@onready var animationlabel = $AnimationLabel

@export var max_value: int = 10

func _ready() -> void:
	if stacksbar:
		stacksbar.max_value = max_value
	if stackslabel:
		stackslabel.text = str(int(0)) + " / " + str(int(stacksbar.max_value))

func update_stacks(stacks):
	if stacksbar:
		stacksbar.value = stacks
	if stackslabel:
		stackslabel.text = str(int(stacks)) + " / " + str(int(stacksbar.max_value))

func update_anim_lanel(anim_name):
	animationlabel.text = anim_name
