extends Control

@export var loading_screen_path: String = "res://Game/MenuScenes/loading_screen.tscn"
@export var target_level_path: String = "res://Game/WorldScenes/main_scene.tscn"

@onready var main_panel = $MainPanel
@onready var settings_panel = $SettingsPanel
@onready var languages_panel = $LanguagesPanel

func _ready() -> void:
	main_panel.visible = true
	settings_panel.visible = false
	languages_panel.visible = false

func _on_button_pressed() -> void:
	GlobalData.target_scene = target_level_path
	get_tree().change_scene_to_file(loading_screen_path)

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
