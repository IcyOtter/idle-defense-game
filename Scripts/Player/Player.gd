extends CharacterBody2D
class_name Player

@onready var health: PlayerHealth = $PlayerHealth
@onready var sprite: Sprite2D = $Sprite2D

var is_dead := false

func _ready() -> void:
	if health != null:
		health.died.connect(_on_died)

func take_damage(amount: int) -> void:
	if is_dead:
		return
	if health != null:
		health.take_damage(amount)

func _on_died() -> void:
	is_dead = true
	sprite.visible = false
	$CollisionShape2D.disabled = true
	set_physics_process(false)
	set_process(false)

