extends Area2D
class_name SpellBase

@export var speed: float = 400.0

var damage: float = 0.0
var mana_cost: float = 0.0
var knockback_power: float = 0.0
var time_of_stun: float = 0.0
var damage_type: String = ""
var element_type: String = ""

@export var explosion_scene: PackedScene = preload("res://Effects/MagicEffects/FireStyleEffects/fireball_explosion_effect.tscn")

@export var shake_intencity: float = 0.0
@export var shake_duration: float = 0.2
@export var is_decaying: bool = true

@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var camera: Camera2D = get_tree().current_scene.find_child("Camera2D", true, false) 

func _ready() -> void:
	particles.local_coords = false

func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	destroy_spell()
	
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage, time_of_stun, knockback_power, element_type, damage_type, global_position)
		
	spawn_explosion()
		
	destroy_spell()

func spawn_explosion() -> void:
	if explosion_scene:
		var effect = explosion_scene.instantiate()
		effect.global_position = global_position
		get_tree().current_scene.add_child(effect)

func destroy_spell() -> void:
	if particles:
		var current_global_pos = particles.global_position
		particles.get_parent().remove_child(particles)
		get_tree().current_scene.add_child(particles)
		
		particles.global_position = current_global_pos
		
		particles.emitting = false
		
		var lifetime = particles.lifetime
		get_tree().create_timer(lifetime).timeout.connect(particles.queue_free)
		
	if camera and camera.has_method("apply_shake"):
		camera.apply_shake(shake_intencity, shake_duration)
		
	queue_free()

func update_stats(DMG, MC, KP, TOS, DT, ET):
	damage = DMG
	mana_cost = MC
	knockback_power = KP
	time_of_stun = TOS
	damage_type = DT
	element_type = ET
