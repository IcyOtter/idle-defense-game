extends CanvasLayer
class_name PlayerUI

@export var player: Player

@onready var health_bar: ProgressBar = $Root/HealthBar

func _ready() -> void:
	if player == null:
		push_warning("PlayerUI: player not assigned.")
		return

	var health: PlayerHealth = player.get_node_or_null("PlayerHealth")
	if health == null:
		push_warning("PlayerUI: PlayerHealth node not found under player.")
		return

	_on_player_health_changed(health.current_health, health.max_health)
	health.health_changed.connect(_on_player_health_changed)

func _on_player_health_changed(current: int, max_health: int) -> void:
	health_bar.max_value = max_health
	health_bar.value = current
