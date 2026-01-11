extends Node
class_name PlayerEquipmentController

@export var weapon_mount: Node2D
@export var player_combat: PlayerCombat

var _weapon_instance: WeaponBase
var _inventory_manager: AL_InventoryManager

func _ready() -> void:
	_inventory_manager = get_node_or_null("/root/AL_InventoryManager") as AL_InventoryManager
	if _inventory_manager != null:
		_inventory_manager.equipment_changed.connect(_on_equipment_changed)
	else:
		push_warning("AL_InventoryManager instance not found at /root/AL_InventoryManager; ensure it's an AutoLoad or adjust the path.")
	_on_equipment_changed()

func _on_equipment_changed() -> void:
	if weapon_mount == null or player_combat == null:
		return

	# Remove old weapon instance
	if _weapon_instance != null and is_instance_valid(_weapon_instance):
		_weapon_instance.queue_free()
	_weapon_instance = null
	player_combat.weapon = null

	if _inventory_manager == null:
		_inventory_manager = get_node_or_null("/root/AL_InventoryManager") as AL_InventoryManager
		if _inventory_manager == null:
			return

	var weapon_item := _inventory_manager.get_equipped_weapon()
	if weapon_item == null:
		return

	if weapon_item.weapon_scene == null:
		push_warning("Equipped weapon has no weapon_scene.")
		return

	var w := weapon_item.weapon_scene.instantiate()
	weapon_mount.add_child(w)

	_weapon_instance = w as WeaponBase
	if _weapon_instance == null:
		push_warning("Equipped weapon scene is not a WeaponBase.")
		return

	# Push weapon_data into the weapon instance
	_weapon_instance.weapon_data = weapon_item.weapon_data

	# Tell PlayerCombat what the active weapon is
	player_combat.weapon = _weapon_instance
