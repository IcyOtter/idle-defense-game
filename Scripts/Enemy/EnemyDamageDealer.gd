extends Area2D
class_name EnemyDamageDealer

@export var enemy_data: EnemyData
@export var tick_rate: float = 0.2

var _targets: Array[CharacterBody2D] = []
var _timer := 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if enemy_data == null or _targets.is_empty():
		return

	_timer += delta
	if _timer < tick_rate:
		return

	_timer = 0.0

	var damage := int(round(enemy_data.contact_dps * tick_rate))
	if damage < 1:
		damage = 1

	for body in _targets:
		if is_instance_valid(body) and body.has_method("take_damage"):
			body.take_damage(damage)

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D and body.has_method("take_damage"):
		_targets.append(body)

func _on_body_exited(body: Node) -> void:
	_targets.erase(body)
