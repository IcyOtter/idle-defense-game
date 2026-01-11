extends Node2D
class_name PlayerCombat

@export var weapon: WeaponBase
@export var targeting_area: Area2D
@export var player: Player

var auto_fire := false
var enemies_in_range: Array[Node2D] = []

func _ready() -> void:
	targeting_area.body_entered.connect(_on_enemy_entered)
	targeting_area.body_exited.connect(_on_enemy_exited)

func _process(_delta: float) -> void:
	if get_tree().paused:
		return
	if player == null or player.is_dead:
		return
	if weapon == null:
		return

	if auto_fire:
		var target := _get_nearest_enemy()
		if target == null:
			return

		weapon.aim_at(target.global_position)

		# Auto-fire = homing behavior for bow
		if weapon is BowWeapon:
			(weapon as BowWeapon).fire_at_target(target)
		else:
			weapon.fire(target.global_position)

func _input(event: InputEvent) -> void:
	if get_tree().paused:
		return
	if player == null or player.is_dead:
		return
	if weapon == null:
		return

	if event.is_action_pressed("toggle_auto_fire"):
		auto_fire = not auto_fire
		return

	# Manual fire only when auto_fire is OFF
	if not auto_fire and event.is_action_pressed("attack"):
		var click_pos := get_global_mouse_position()

		weapon.aim_at(click_pos)

		if weapon is BowWeapon:
			(weapon as BowWeapon).fire_at_position(click_pos)
		else:
			weapon.fire(click_pos)

func _get_nearest_enemy() -> Node2D:
	var nearest: Node2D = null
	var shortest := INF

	for enemy in enemies_in_range:
		if not is_instance_valid(enemy):
			continue

		var dist := global_position.distance_squared_to(enemy.global_position)
		if dist < shortest:
			shortest = dist
			nearest = enemy

	return nearest

func _on_enemy_entered(body: Node) -> void:
	if body.is_in_group("enemies"):
		enemies_in_range.append(body as Node2D)

func _on_enemy_exited(body: Node) -> void:
	enemies_in_range.erase(body)
