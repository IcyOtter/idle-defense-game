extends Node2D
class_name EnemySpawner

signal wave_started(wave_index: int)
signal wave_finished(wave_index: int)
signal schedule_finished

@export var schedule: SpawnerSchedule
@export var spawn_points: Array[Node2D] = []
@export var spawn_parent: Node = null  # if null, spawns into current_scene

var _current_wave_index := -1
var _is_running := false
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
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

	if wave.start_delay > 0.0:
		await get_tree().create_timer(wave.start_delay).timeout

	# Build a spawn queue: expand entries into a list of scenes to spawn
	var queue: Array[PackedScene] = []
	for entry in wave.entries:
		if entry == null or entry.enemy_scene == null:
			continue
		var c: int = max(int(entry.count), 0)
		for i in range(c):
			queue.append(entry.enemy_scene)

	# Spawn them in order (optionally shuffle for variety)
	# queue.shuffle() # uncomment if you want random order per wave

	for enemy_scene in queue:
		if not _is_running:
			return
		_spawn_enemy(enemy_scene)
		if wave.spawn_interval > 0.0:
			await get_tree().create_timer(wave.spawn_interval).timeout

	emit_signal("wave_finished", wave_index)

	if wave.end_delay > 0.0:
		await get_tree().create_timer(wave.end_delay).timeout

func _spawn_enemy(enemy_scene: PackedScene) -> void:
	var enemy := enemy_scene.instantiate()
	if enemy is Node2D:
		(enemy as Node2D).global_position = _pick_spawn_point().global_position

	spawn_parent.add_child(enemy)

func _pick_spawn_point() -> Node2D:
	# Random spawn point for lane variety
	return spawn_points[_rng.randi_range(0, spawn_points.size() - 1)]
