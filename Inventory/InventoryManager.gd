extends Node
class_name InventoryManager

signal inventory_changed
signal equipment_changed

enum EquipSlot { WEAPON }

@export var inventory_size: int = 24

var inventory: Array[ItemStack] = []
var equipment := {
	EquipSlot.WEAPON: null
}

func _ready() -> void:
	# initialize inventory slots
	inventory.resize(inventory_size)
	for i in inventory_size:
		inventory[i] = ItemStack.new()

func get_stack(index: int) -> ItemStack:
	return inventory[index]

func set_stack(index: int, stack: ItemStack) -> void:
	inventory[index] = stack
	emit_signal("inventory_changed")

func add_item(item: ItemData, amount: int = 1) -> bool:
	# Simple non-stacking default; stacking can be added later.
	for i in inventory.size():
		if inventory[i].is_empty():
			var s := ItemStack.new()
			s.item = item
			s.amount = amount
			inventory[i] = s
			emit_signal("inventory_changed")
			return true
	return false

func remove_one(index: int) -> void:
	var s := inventory[index]
	if s.is_empty():
		return
	s.amount -= 1
	if s.amount <= 0:
		inventory[index] = ItemStack.new()
	emit_signal("inventory_changed")

func equip_weapon_from_inventory(index: int) -> void:
	var s := inventory[index]
	if s.is_empty():
		return
	if not (s.item is WeaponItemData):
		return

	var weapon_item := s.item as WeaponItemData

	# Swap currently equipped weapon back into inventory (if any)
	var old := equipment[EquipSlot.WEAPON] as WeaponItemData
	if old != null:
		_add_to_first_empty_slot(old)

	equipment[EquipSlot.WEAPON] = weapon_item

	# Remove from inventory
	inventory[index] = ItemStack.new()

	emit_signal("inventory_changed")
	emit_signal("equipment_changed")

func unequip_weapon_to_inventory() -> void:
	var equipped := equipment[EquipSlot.WEAPON] as WeaponItemData
	if equipped == null:
		return
	if _add_to_first_empty_slot(equipped):
		equipment[EquipSlot.WEAPON] = null
		emit_signal("inventory_changed")
		emit_signal("equipment_changed")

func get_equipped_weapon() -> WeaponItemData:
	return equipment[EquipSlot.WEAPON] as WeaponItemData

func _add_to_first_empty_slot(item: ItemData) -> bool:
	for i in inventory.size():
		if inventory[i].is_empty():
			var s := ItemStack.new()
			s.item = item
			s.amount = 1
			inventory[i] = s
			return true
	return false
