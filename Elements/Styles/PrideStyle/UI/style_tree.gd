extends Control

@onready var name_label = $"../VBoxContainer/NameLabel"
@onready var mana_cost_label = $"../VBoxContainer/ManaCostLabel"
@onready var damage_label = $"../VBoxContainer/DamageLabel"

var dragging := false
var drag_offset := Vector2.ZERO

var resources_folder = "res://Elements/Styles/PrideStyle/PrideAttackResource/"
var resources := []

func _ready():
	var dir = DirAccess.open(resources_folder)

	if dir:
		for file_name in dir.get_files():
			if file_name.ends_with(".tres"):
				resources.append(load(resources_folder + file_name))

	for button in self.get_children():	
		if button is Button:
			button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
	
	for button in get_children():
		if button is Button:
			button.focus_mode = Control.FOCUS_NONE

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_offset = global_position - event.global_position
			else:
				dragging = false

	elif event is InputEventMouseMotion and dragging:	
		global_position = event.global_position + drag_offset

func _on_button_mouse_entered(button: Button) -> void:
	for resource in resources:
		if button.name == resource.id:
			name_label.text = tr("Name: ") + str(resource.animation_name)
			mana_cost_label.text = tr("Mana cost: ") + str(resource.mana_cost)
			damage_label.text = tr("Damage: ") + str(resource.damage)
			return
