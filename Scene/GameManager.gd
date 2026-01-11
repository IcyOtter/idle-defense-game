extends Node2D

@export var inventory_ui: InventoryUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AL_InventoryManager.add_item(preload("res://Assets/Weapons/Basic Bow/idBasicBow.tres"))
	AL_InventoryManager.equip_weapon_from_inventory(0)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		print("toggle_inventory pressed (manager)") # temp
		if inventory_ui != null:
			inventory_ui.toggle()
			get_viewport().set_input_as_handled()

