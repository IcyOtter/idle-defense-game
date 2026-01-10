extends WeaponBase
class_name BowWeapon

@export var fire_point: Node2D

func _spawn_projectile(target_position: Vector2) -> void:
	if weapon_data == null or weapon_data.projectile_scene == null:
		return

	var projectile = weapon_data.projectile_scene.instantiate()
	projectile.global_position = fire_point.global_position

	# Important: add to the SceneTree BEFORE calling initialize()
	get_tree().current_scene.add_child(projectile)

	var direction := (target_position - fire_point.global_position).normalized()

	# Now it's safe: projectile.get_tree() is not null
	projectile.initialize(
		weapon_data.damage,
		weapon_data.projectile_speed,
		weapon_data.projectile_lifetime,
		direction
	)
