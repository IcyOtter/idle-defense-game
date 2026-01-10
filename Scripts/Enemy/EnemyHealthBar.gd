extends Node2D
class_name EnemyHealthBar2D

@export var health_path: NodePath = NodePath("../EnemyHealth")

@export var bar_size: Vector2 = Vector2(36, 6)
@export var y_offset: float = -28.0

@export var show_when_full: bool = false
@export var hide_when_empty: bool = true

var _current: int = 1
var _max: int = 1

@onready var _health: EnemyHealth = get_node_or_null(health_path) as EnemyHealth

func _ready() -> void:
	# Position the bar above the enemy (local space)
	position.y = y_offset

	if _health == null:
		push_warning("EnemyHealthBar2D: EnemyHealth not found at path: %s" % [health_path])
		return

	# Initialize from EnemyHealth
	_current = _health.current_health
	_max = _health.get_max_health()

	_update_visibility()
	queue_redraw()

	# Subscribe to health updates
	_health.health_changed.connect(_on_health_changed)

func _on_health_changed(current: int, max_health: int) -> void:
	_current = current
	_max = max_health
	_update_visibility()
	queue_redraw()

func _update_visibility() -> void:
	if hide_when_empty and _current <= 0:
		visible = false
		return

	if not show_when_full and _max > 0 and _current >= _max:
		visible = false
		return

	visible = true

func _draw() -> void:
	if _max <= 0:
		return

	var pct: float = clamp(float(_current) / float(_max), 0.0, 1.0)

	var w := bar_size.x
	var h := bar_size.y
	var top_left := Vector2(-w * 0.5, -h * 0.5)

	# Background
	draw_rect(Rect2(top_left, bar_size), Color(0, 0, 0, 0.7), true)

	# Fill
	draw_rect(Rect2(top_left, Vector2(w * pct, h)), Color(0.2, 0.9, 0.2, 0.9), true)

	# Border
	draw_rect(Rect2(top_left, bar_size), Color(0, 0, 0, 1.0), false, 1.0)
