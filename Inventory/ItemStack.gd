extends Resource
class_name ItemStack

@export var item: ItemData
@export var amount: int = 1

func is_empty() -> bool:
	return item == null or amount <= 0
