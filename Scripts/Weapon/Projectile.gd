extends Area2D
class_name Projectile

var damage: int
var speed: float
var lifetime: float

var _direction: Vector2

func initialize(
	p_damage: int,
	p_speed: float,
	p_lifetime: float,
	p_direction: Vector2
) -> void:
	damage = p_damage
	speed = p_speed
	lifetime = p_lifetime
	_direction = p_direction.normalized()

	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position += _direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
