extends Node
class_name PlayerHealth

signal health_changed(current: int, max: int)
signal died

@export var max_health: int = 100

var current_health: int

func _ready() -> void:
	current_health = max_health
	emit_signal("health_changed", current_health, max_health)

func take_damage(amount: int) -> void:
	if amount <= 0 or current_health <= 0:
		return

	current_health = max(current_health - amount, 0)
	emit_signal("health_changed", current_health, max_health)
	print("Player HP:", current_health)


	if current_health == 0:
		emit_signal("died")
