extends Area2D
class_name Interactable

@onready var label: Label = $Label

@export var promt: String 

func _ready() -> void:
	if label:
		label.visible = false
		label.text = promt + " F"
		
func show_hide_label() -> void:
	if label:
		label.visible = not label.visible

func interact(_player: CharacterBody2D):
	print("Interact")
