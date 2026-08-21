extends Control

@export var loading_screen_path: String = "res://Game/MenuScenes/loading_screen.tscn"
@export var target_level_path: String = "res://Game/WorldScenes/main_scene.tscn"

@onready var main_panel = $MainPanel
@onready var settings_panel = $SettingsPanel
@onready var languages_panel = $LanguagesPanel
@onready var saves_panel = $Saves
@onready var saves_container = $Saves/ButtonsContainer/SavesContainer
@onready var delete_container = $Saves/ButtonsContainer/DeleteButtonContainer

var save_number = 1
var delete_number = 1

func _ready() -> void:
	main_panel.visible = true
	settings_panel.visible = false
	languages_panel.visible = false

	var saves_buttons = saves_container.get_children()
	var delete_buttons = delete_container.get_children()

	for button in saves_buttons:	
		if button is Button:
			button.pressed.connect(_on_save_pressed.bind(save_number))
			save_number += 1

	for button in delete_buttons:
		if button is Button:
			button.pressed.connect(_on_delete_pressed.bind(delete_number))
			delete_number += 1

func _on_save_pressed(slot: int) -> void:
	SaveManager.current_save = slot
	if SaveManager.has_save(slot):
		var save = SaveManager.load_save(slot)
		GameManager.load_game(slot)
		GlobalData.target_scene = save["scene_path"]
		get_tree().change_scene_to_file(loading_screen_path)
	else:
		GlobalData.target_scene = target_level_path
		get_tree().change_scene_to_file(loading_screen_path)

func _on_delete_pressed(slot: int) -> void:
	SaveManager.delete_save(slot)

func _on_button_pressed() -> void:
		saves_panel.visible = true
		main_panel.visible = false

func _on_settings_pressed() -> void:
	main_panel.visible = false
	settings_panel.visible = true

func _on_languages_pressed() -> void:
	settings_panel.visible = false
	languages_panel.visible = true

func _on_ru_pressed() -> void:
	TranslationServer.set_locale("ru")

func _on_en_pressed() -> void:
	TranslationServer.set_locale("en")

func _on_backlanguages_pressed() -> void:
	languages_panel.visible = false
	settings_panel.visible = true

func _on_backsettings_pressed() -> void:
	settings_panel.visible = false
	main_panel.visible = true

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_back_to_main_pressed() -> void:
	saves_panel.visible = false
	main_panel.visible = true
