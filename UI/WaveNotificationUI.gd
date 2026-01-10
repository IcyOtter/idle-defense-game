extends CanvasLayer
class_name WaveNotificationUI

@export var spawner: EnemySpawner
@export var display_seconds: float = 1.5

@onready var message: Label = $Root/Message

var _hide_timer: SceneTreeTimer

func _ready() -> void:
	message.visible = false

	if spawner == null:
		push_warning("WaveNotificationUI: spawner not assigned.")
		return

	# Subscribe to wave cleared
	spawner.wave_finished.connect(_on_wave_finished)

func _on_wave_finished(wave_index: int) -> void:
	# wave_index is 0-based; display as 1-based
	message.text = "Wave %d cleared!" % (wave_index + 1)
	message.visible = true

	# Cancel any prior timer by simply starting a new one
	if _hide_timer != null:
		# No direct cancel needed; just replace it
		_hide_timer = null

	_hide_timer = get_tree().create_timer(display_seconds)
	_hide_timer.timeout.connect(_hide_message)

func _hide_message() -> void:
	message.visible = false
