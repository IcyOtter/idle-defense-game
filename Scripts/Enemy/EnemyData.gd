extends Resource
class_name EnemyData

@export var max_health: int = 10

@export var move_speed: float = 50.0
@export var chase_range: float = 2000.0      # how far away the enemy can “see” the player
@export var stop_distance: float = 18.0      # stop moving when within this distance

@export var contact_dps: float = 5.0

@export var gold_reward: int = 1
@export var xp_reward: int = 1
