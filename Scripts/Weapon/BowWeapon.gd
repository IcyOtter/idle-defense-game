extends WeaponBase
class_name BowWeapon

@export var fire_point: Node2D

var _last_target: Node2D = null

func fire_at_target(target: Node2D) -> void:
	_last_target = target
	fire(target.global_position)

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

	# IMPORTANT: only pass a live Node2D
	var target_node: Node2D = null
	if _last_target != null and is_instance_valid(_last_target):
		target_node = _last_target

	projectile.initialize(
		weapon_data.damage,
		weapon_data.projectile_speed,
		weapon_data.projectile_lifetime,
		direction,
		target_node,
		weapon_data.homing_enabled,
		weapon_data.turn_rate_rad
	)

	_last_target = null
