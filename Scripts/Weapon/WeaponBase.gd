extends Node2D
class_name WeaponBase

@export var weapon_data: WeaponData

var _cooldown := 0.0

func _process(delta: float) -> void:
	if _cooldown > 0.0:
		_cooldown -= delta

func can_fire() -> bool:
	return weapon_data != null and _cooldown <= 0.0

func aim_at(world_pos: Vector2) -> void:
	look_at(world_pos)

func fire(target_position: Vector2) -> void:
	if not can_fire():
		return
	_cooldown = 1.0 / weapon_data.fire_rate
	_spawn_projectile(target_position)

func _spawn_projectile(_target_position: Vector2) -> void:
	pass
