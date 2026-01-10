extends Resource
class_name EnemyData

# Movement
@export var move_speed: float = 50.0

# Health
@export var max_health: int = 10

#Rewards
@export var gold_reward: int = 1
@export var xp_reward: int = 1

# Damage Data
@export var contact_damage: int = 1
@export var contact_ticks_per_second: float = 2.0
@export var contact_range: float = 24.0