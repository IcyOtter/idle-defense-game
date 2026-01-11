extends Node2D
class_name EnemySpawner

signal wave_started(wave_index: int)
signal wave_finished(wave_index: int)
signal wave_cleared(wave_index: int)
signal schedule_finished

@export var schedule: SpawnerSchedule
@export var spawn_points: Array[Node2D] = []
@export var spawn_parent: Node = null  # if null, spawns into current_scene

var _current_wave_index := 0
var _is_running := false
var _rng := RandomNumberGenerator.new()

# Clear-all tracking
var _alive_in_wave: int = 0
var _wave_spawn_complete: bool = false
var _tracked_ids: Dictionary = {} # instance_id -> true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_rng.randomize()
	if spawn_parent == null:
		spawn_parent = get_tree().current_scene
	start()

func start() -> void:
	if schedule == null or schedule.waves.is_empty():
		push_warning("EnemySpawner: No schedule/waves assigned.")
		return
	if spawn_points.is_empty():
		push_warning("EnemySpawner: No spawn points assigned.")
		return
	if _is_running:
		return

	_is_running = true
	_current_wave_index = 0
	_run_schedule()

func stop() -> void:
	_is_running = false

func _run_schedule() -> void:
	while _is_running:
		if _current_wave_index >= schedule.waves.size():
			if schedule.loop:
				_current_wave_index = 0
			else:
				emit_signal("schedule_finished")
				_is_running = false
				return

		await _run_wave(_current_wave_index)
		_current_wave_index += 1

func _run_wave(wave_index: int) -> void:
	var wave := schedule.waves[wave_index]
	emit_signal("wave_started", wave_index)

	# Reset tracking for this wave
	_alive_in_wave = 0
	_wave_spawn_complete = false
	_tracked_ids.clear()

	if wave.start_delay > 0.0:
		await get_tree().create_timer(wave.start_delay, false).timeout

	# Build spawn queue
	var queue: Array[PackedScene] = []
	for entry in wave.entries:
		if entry == null or entry.enemy_scene == null:
			continue
		var c: int = int(entry.count)
		if c < 0:
			c = 0
		for i in range(c):
			queue.append(entry.enemy_scene)

	print("Wave", wave_index, "spawning:", queue.size(), "enemies")

	# Spawn all enemies in this wave
	for enemy_scene in queue:
		if not _is_running:
			return
		_spawn_enemy(enemy_scene, wave_index)
		if wave.spawn_interval > 0.0:
			await get_tree().create_timer(wave.spawn_interval, false).timeout

	_wave_spawn_complete = true
	print("Wave", wave_index, "spawn complete. Alive:", _alive_in_wave)

	if _alive_in_wave == 0:
		print("EMIT wave_cleared wave:", wave_index, "(immediate)")
		emit_signal("wave_cleared", wave_index)
		
	# Wait until all tracked enemies are gone (only if any were spawned)
	if _alive_in_wave > 0:
		await wave_cleared

	emit_signal("wave_finished", wave_index)

	if wave.end_delay > 0.0:
		await get_tree().create_timer(wave.end_delay, false).timeout

func _spawn_enemy(enemy_scene: PackedScene, wave_index: int) -> void:
	var enemy := enemy_scene.instantiate()

	if enemy is Node2D:
		(enemy as Node2D).global_position = _pick_spawn_point().global_position

	spawn_parent.add_child(enemy)

	# Track enemy
	var id := enemy.get_instance_id()
	_tracked_ids[id] = true
	_alive_in_wave += 1

	print("Spawned enemy id:", id, "alive now:", _alive_in_wave)

	enemy.tree_exited.connect(_on_tracked_enemy_exited.bind(id, wave_index))

func _pick_spawn_point() -> Node2D:
	return spawn_points[_rng.randi_range(0, spawn_points.size() - 1)]

func _on_tracked_enemy_exited(id: int, wave_index: int) -> void:
	if not _tracked_ids.has(id):
		return

	_tracked_ids.erase(id)
	_alive_in_wave = max(_alive_in_wave - 1, 0)

	print("Enemy exited id:", id, "alive now:", _alive_in_wave)

	if _wave_spawn_complete and _alive_in_wave == 0:
		print("EMIT wave_cleared wave:", wave_index)
		emit_signal("wave_cleared", wave_index)
