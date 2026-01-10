extends Resource
class_name WaveData

@export var entries: Array[EnemySpawnEntry] = []

@export var spawn_interval: float = 0.75  # time between individual spawns
@export var start_delay: float = 1.0      # delay before wave begins
@export var end_delay: float = 2.0        # delay after wave completes
