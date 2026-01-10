extends Resource
class_name WeaponData

@export var damage: int = 1
@export var fire_rate: float = 1.0

@export var projectile_speed: float = 600.0
@export var projectile_lifetime: float = 3.0
@export var homing_enabled: bool = true
@export var turn_rate_rad: float = 12.0  # radians/sec, higher = sharper turns


@export var attack_range: float = 300.0
@export var projectile_scene: PackedScene
