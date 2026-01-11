extends WeaponBase
class_name BowWeapon

@export var fire_point: Node2D

var _last_target: Node2D = null
var _use_homing_for_this_shot: bool = false

func fire_at_target(target: Node2D) -> void:
	if target == null or not is_instance_valid(target):
		return
	_last_target = target
	_use_homing_for_this_shot = true
	fire(target.global_position)

func fire_at_position(world_pos: Vector2) -> void:
	_last_target = null
	_use_homing_for_this_shot = false
	fire(world_pos)

func _spawn_projectile(target_position: Vector2) -> void:
	if weapon_data == null or weapon_data.projectile_scene == null:
		return
	if fire_point == null:
		push_warning("BowWeapon: fire_point not assigned.")
		return

	var projectile: Projectile = weapon_data.projectile_scene.instantiate()
	projectile.global_position = fire_point.global_position
	get_tree().current_scene.add_child(projectile)

	var direction := (target_position - fire_point.global_position).normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT

	var target_node: Node2D = null
	if _use_homing_for_this_shot and _last_target != null and is_instance_valid(_last_target):
		target_node = _last_target

	projectile.initialize(
		weapon_data.damage,
		weapon_data.projectile_speed,
		weapon_data.projectile_lifetime,
		direction,
		target_node,
		_use_homing_for_this_shot,
		weapon_data.turn_rate_rad
	)

	_last_target = null
	_use_homing_for_this_shot = false

