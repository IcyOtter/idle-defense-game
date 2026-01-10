extends Area2D
class_name Projectile

var damage: int
var speed: float
var lifetime: float

var homing_enabled: bool = false
var turn_rate_rad: float = 12.0

var _direction: Vector2 = Vector2.RIGHT
var _target_ref: WeakRef

func initialize(
	p_damage: int,
	p_speed: float,
	p_lifetime: float,
	p_initial_direction: Vector2,
	p_target: Object = null,
	p_homing_enabled: bool = false,
	p_turn_rate_rad: float = 12.0
) -> void:
	damage = p_damage
	speed = p_speed
	lifetime = p_lifetime
	homing_enabled = p_homing_enabled
	turn_rate_rad = p_turn_rate_rad

	_direction = p_initial_direction.normalized()

	if p_target != null and p_target is Node2D and is_instance_valid(p_target):
		_target_ref = weakref(p_target as Node2D)
	else:
		_target_ref = null

	if is_inside_tree():
		_start_lifetime_timer()
	else:
		call_deferred("_start_lifetime_timer")

func _start_lifetime_timer() -> void:
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	# If homing, gently rotate direction toward current target position
	if homing_enabled and _target_ref != null:
		var target: Node2D = _target_ref.get_ref() as Node2D
		if target != null and is_instance_valid(target):
			var desired: Vector2 = (target.global_position - global_position).normalized()
			_direction = _rotate_toward(_direction, desired, turn_rate_rad * delta)

	# Move and face along travel direction
	global_position += _direction * speed * delta
	rotation = _direction.angle()

func _rotate_toward(from_dir: Vector2, to_dir: Vector2, max_radians: float) -> Vector2:
	var from_angle := from_dir.angle()
	var to_angle := to_dir.angle()
	var new_angle := lerp_angle(from_angle, to_angle, clamp(max_radians / max(0.0001, abs(ang_diff(from_angle, to_angle))), 0.0, 1.0))
	return Vector2.RIGHT.rotated(new_angle)

func ang_diff(a: float, b: float) -> float:
	return wrapf(b - a, -PI, PI)

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
