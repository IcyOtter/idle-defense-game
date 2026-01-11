extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AL_InventoryManager.add_item(preload("res://Assets/Weapons/Basic Bow/idBasicBow.tres"))
	AL_InventoryManager.equip_weapon_from_inventory(0)


