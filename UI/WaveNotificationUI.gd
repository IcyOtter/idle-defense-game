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

	var cb := Callable(self, "_on_wave_cleared")

	if spawner.has_signal("wave_cleared") and not spawner.is_connected("wave_cleared", cb):
		spawner.connect("wave_cleared", cb)




func _on_wave_cleared(wave_index: int) -> void:
	print("UI RECEIVED wave_cleared:", wave_index)
	message.text = "Wave %d cleared!" % (wave_index + 1)
	message.visible = true
	_hide_timer = get_tree().create_timer(display_seconds)
	_hide_timer.timeout.connect(_hide_message)

	# Cancel any prior timer by simply starting a new one
	if _hide_timer != null:
		# No direct cancel needed; just replace it
		_hide_timer = null

	_hide_timer = get_tree().create_timer(display_seconds)
	_hide_timer.timeout.connect(_hide_message)

func _hide_message() -> void:
	message.visible = false
