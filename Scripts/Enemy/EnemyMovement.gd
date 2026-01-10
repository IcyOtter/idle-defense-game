extends Node
class_name EnemyMovement

@export var stats: EnemyData
@export var move_direction: Vector2 = Vector2.LEFT
@export var is_active: bool = true

@onready var body: CharacterBody2D = get_parent() as CharacterBody2D

func _physics_process(_delta: float) -> void:
	if not is_active or stats == null or body == null:
		return

	body.velocity = move_direction.normalized() * stats.move_speed
	body.move_and_slide()