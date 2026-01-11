extends Node2D
class_name PlayerCombat

@export var weapon: WeaponBase
@export var targeting_area: Area2D

var auto_fire := false
var enemies_in_range: Array[Node2D] = []
@export var player: Player

func _ready() -> void:
	targeting_area.body_entered.connect(_on_enemy_entered)
	targeting_area.body_exited.connect(_on_enemy_exited)

func _process(_delta: float) -> void:
	if player == null or player.is_dead:
		return
	if weapon == null:
		return

	var target := _get_nearest_enemy()
	if target == null:
		return

	weapon.aim_at(target.global_position)

	if auto_fire:
		if weapon is BowWeapon:
			(weapon as BowWeapon).fire_at_target(target)
		else:
			weapon.fire(target.global_position)

func _input(event: InputEvent) -> void:
	if player == null or player.is_dead:
		return

	if weapon == null:
		return

	if event.is_action_pressed("attack"):
		var target := _get_nearest_enemy()
		if target:
			weapon.fire(target.global_position)

	if event.is_action_pressed("toggle_auto_fire"):
		auto_fire = not auto_fire



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
		enemies_in_range.append(body)


func _on_enemy_exited(body: Node) -> void:
	enemies_in_range.erase(body)
