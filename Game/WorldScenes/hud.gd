extends Control

@onready var hpbar: ProgressBar = $BarsContainer/HealthBar
@onready var mpbar: ProgressBar = $BarsContainer/ManaBar

@onready var hplabel: Label = $BarsContainer/HealthBar/Label
@onready var mplabel: Label = $BarsContainer/ManaBar/Label 

@onready var maxhplabel: Label = $TabMenu/VBoxContainer/HP
@onready var maxmplabel: Label = $TabMenu/VBoxContainer/MP
@onready var cclabel: Label = $TabMenu/VBoxContainer/CC
@onready var cdlabel: Label = $TabMenu/VBoxContainer/CD

@onready var combo_keys: Label = $ComboLabel

@onready var pause_menu: PanelContainer = $PauseMenu
@onready var styles_menu: PanelContainer = $StylesMenu
@onready var tab_menu: PanelContainer = $TabMenu

@onready var styles_container: HBoxContainer = $StylesMenu/StylesContainer

@onready var player: CharacterBody2D = $"../../Player"
@export var styles: Array[ItemData] = []

var button_id

func setup_bar(max_hp: float, max_mp: float) -> void:
	if hpbar and mpbar:
		hpbar.max_value = max_hp
		mpbar.value = max_hp
		hplabel.text = str(int(max_hp)) + " / " + str(int(max_hp))
		
		mpbar.max_value = max_mp
		mpbar.value = max_mp
		mplabel.text = str(int(max_mp)) + " / " + str(int(max_mp))
		
func update_hp_bar(hp: float) -> void:
	if hpbar:
		hpbar.value = hp
		hplabel.text = str(int(hp)) + " / " + str(int(hpbar.max_value))
		
func update_mp_bar(mp: float) -> void:
	if mpbar:
		mpbar.value = mp
		mplabel.text = str(int(mp)) + " / " + str(int(mpbar.max_value))
		
func update_static_labels(max_hp: float, max_mp: float, crit_chance: float, crit_damage: float):
	if maxhplabel:
		maxhplabel.text = tr("KEY_MAX_HP") + ": " + (str(max_hp))
	if maxmplabel:
		maxmplabel.text = tr("KEY_MAX_HP") + ": " + (str(max_mp))
	if cclabel:
		cclabel.text = tr("KEY_CC") + ": " + (str(crit_chance))
	if cdlabel:
		cdlabel.text = tr("KEY_CD") + ": " + (str(crit_damage))

func update_combo_label(input_history):
	if combo_keys.text.is_empty():
		combo_keys.text = tr("KEY_COMBO") + ": " + tr("KEY_EMPTY")
	else:
		combo_keys.text = "+".join(input_history)
		
func _ready() -> void:
	if pause_menu:
		pause_menu.visible = false
	if styles_menu:
		styles_menu.visible = false
	if tab_menu:
		tab_menu.visible = false
		
	self.visible = true
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		tab_menu.visible = false
		toggle_pause()
	if event.is_action_pressed("tab_menu"):
		tab_menu.visible = not tab_menu.visible

func toggle_pause() -> void:
	if pause_menu:
		pause_menu.visible = not pause_menu.visible
		
		get_tree().paused = pause_menu.visible

func _on_resume_button_pressed() -> void:
	toggle_pause()

func _on_quit_to_menu_button_pressed() -> void:
	get_tree().paused = false
	GlobalData.target_scene = ""
	get_tree().change_scene_to_file("res://Game/MenuScenes/main_menu.tscn")

func _on_change_styles_button_pressed() -> void:
	pause_menu.visible = false
	styles_menu.visible = true
	if styles_container.get_child_count() < len(styles):
		for style in styles:
			create_button_style(style)

func create_button_style(style):
	var new_button := Button.new()
	new_button.icon = style.icon	
	styles_container.add_child(new_button)
		
	new_button.pressed.connect(player.fill_slot.bind(style.path))

func _on_back_to_pause_pressed() -> void:
	pause_menu.visible = true
	styles_menu.visible = false
	
func _on_continue_pressed() -> void:
	pause_menu.visible = false
	styles_menu.visible = false
	get_tree().paused = false
