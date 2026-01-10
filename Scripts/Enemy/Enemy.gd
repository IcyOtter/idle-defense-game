extends CharacterBody2D
class_name Enemy

@export var stats: EnemyData

@onready var health: EnemyHealth = $EnemyHealth

func _ready() -> void:
	# Ensure the health component uses the same stats resource
	if health != null:
		health.stats = stats
		health.died.connect(_on_died)

func take_damage(amount: int) -> void:
	if health != null:
		health.take_damage(amount)

func _on_died() -> void:
	# Later: spawn death VFX, give gold/xp, notify wave manager, etc.
	queue_free()
