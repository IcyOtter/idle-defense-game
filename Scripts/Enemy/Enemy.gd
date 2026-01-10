extends CharacterBody2D
class_name Enemy

@export var data: EnemyData

# Optional: if you keep these as child components
@onready var damage_dealer: EnemyDamageDealer = $EnemyDamageDealer
@onready var health: EnemyHealth = $EnemyHealth

# Targeting
@export var target_path: NodePath  # optional override
var _target: Node2D

func _ready() -> void:
	# Wire components to shared data (single source of truth)
	if health != null:
		health.data = data
		health.died.connect(_on_died)

	if damage_dealer != null:
		damage_dealer.enemy_data = data

	_resolve_target()

func _physics_process(_delta: float) -> void:
	if data == null:
		return

	if _target == null or not is_instance_valid(_target):
		_resolve_target()
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Stop moving close to the player; let contact damage handle damage ticks
	var to_target := _target.global_position - global_position
	var dist := to_target.length()

	# If you added these to EnemyData:
	# chase_range, stop_distance
	if dist > data.chase_range:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if dist <= data.stop_distance:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	velocity = to_target.normalized() * data.move_speed
	move_and_slide()

func _resolve_target() -> void:
	_target = null

	# 1) explicit path, if provided
	if target_path != NodePath("") and has_node(target_path):
		var n := get_node(target_path)
		if n is Node2D:
			_target = n
			return

	# 2) by group
	var found := get_tree().get_first_node_in_group("player")
	if found is Node2D:
		_target = found

func take_damage(amount: int) -> void:
	if health != null:
		health.take_damage(amount)

func _on_died() -> void:
	queue_free()
