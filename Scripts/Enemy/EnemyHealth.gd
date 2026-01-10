extends Node
class_name EnemyHealth

signal health_changed(current: int, max: int)
signal died

@export var stats: EnemyData

var current_health: int

func _ready() -> void:
	if stats == null:
		push_warning("EnemyHealth has no stats assigned.")
		current_health = 1
	else:
		current_health = stats.max_health

	emit_signal("health_changed", current_health, get_max_health())

func get_max_health() -> int:
	return stats.max_health if stats != null else 1

func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	if current_health <= 0:
		return

	current_health = max(current_health - amount, 0)
	emit_signal("health_changed", current_health, get_max_health())

	if current_health == 0:
		emit_signal("died")
