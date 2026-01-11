extends CanvasLayer
class_name InventoryUI

@export var row_scene: PackedScene

@onready var list: VBoxContainer = $Root/Window/InventoryList
@onready var weapon_slot: Button = $Root/Window/Equipment/WeaponSlot
@onready var window: Control = $Root/Window

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED  # so it can close itself after pausing
	window.visible = false                        # start closed

	AL_InventoryManager.inventory_changed.connect(_refresh)
	AL_InventoryManager.equipment_changed.connect(_refresh)

	weapon_slot.pressed.connect(_on_weapon_slot_pressed)
	_refresh()


func _refresh() -> void:
	# Clear list
	for c in list.get_children():
		c.queue_free()

	# Build rows
	for i in AL_InventoryManager.inventory.size():
		var stack := AL_InventoryManager.get_stack(i)
		if stack.is_empty():
			continue

		var row := row_scene.instantiate() as Button
		list.add_child(row)

		row.text = _format_stack_text(stack)
		row.tooltip_text = stack.item.description

		row.pressed.connect(_on_row_pressed.bind(i))

	# Equipment slot
	var eq := AL_InventoryManager.get_equipped_weapon()
	if eq == null:
		weapon_slot.text = "Weapon: (empty)"
	else:
		weapon_slot.text = "Weapon: %s" % eq.display_name

func _format_stack_text(stack: ItemStack) -> String:
	if stack.amount > 1:
		return "%s x%d" % [stack.item.display_name, stack.amount]
	return stack.item.display_name

func _on_row_pressed(index: int) -> void:
	var stack := AL_InventoryManager.get_stack(index)
	if stack.is_empty():
		return

	if stack.item is WeaponItemData:
		AL_InventoryManager.equip_weapon_from_inventory(index)

func _on_weapon_slot_pressed() -> void:
	AL_InventoryManager.unequip_weapon_to_inventory()

func toggle() -> void:
	var opening := not window.visible

	if opening:
		window.visible = true
		get_tree().paused = true
	else:
		get_tree().paused = false
		window.visible = false
