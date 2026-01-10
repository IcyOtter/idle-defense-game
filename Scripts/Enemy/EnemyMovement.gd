extends CharacterBody2D
class_name EnemyMovement

@export var data: EnemyData
@export var target_path: NodePath  # optional override; leave empty to auto-find by group

var _target: Node2D

func _ready() -> void:
	_resolve_target()

func _physics_process(_delta: float) -> void:
	if data == null:
		return

	if _target == null or not is_instance_valid(_target):
		_resolve_target()
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# If player has a death flag, stop chasing when dead
	if _target.has_variable("is_dead") and _target.get("is_dead") == true:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var to_target := _target.global_position - global_position
	var dist := to_target.length()

	# Out of chase range -> stop (or you can idle)
	if dist > data.chase_range:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Within stop distance -> stop, let contact damage handle the rest
	if dist <= data.stop_distance:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	velocity = to_target.normalized() * data.move_speed
	move_and_slide()

func _resolve_target() -> void:
	_target = null

	# 1) explicit path (best for some scenes)
	if target_path != NodePath("") and has_node(target_path):
		var n := get_node(target_path)
		if n is Node2D:
			_target = n
			return

	# 2) by group (best for reusability)
	var found := get_tree().get_first_node_in_group("player")
	if found is Node2D:
		_target = found
