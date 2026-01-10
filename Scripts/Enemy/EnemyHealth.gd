extends Node
class_name EnemyHealth

signal health_changed(current: int, max: int)
signal died

@export var data: EnemyData

var current_health: int = 1

func _ready() -> void:
	if data == null:
		push_warning("EnemyHealth: EnemyData not assigned.")
		current_health = 1
	else:
		current_health = data.max_health

	emit_signal("health_changed", current_health, get_max_health())

func get_max_health() -> int:
	return data.max_health if data != null else 1

func take_damage(amount: int) -> void:
	if amount <= 0 or current_health <= 0:
		return

	current_health = max(current_health - amount, 0)
	emit_signal("health_changed", current_health, get_max_health())

	if current_health == 0:
		emit_signal("died")
