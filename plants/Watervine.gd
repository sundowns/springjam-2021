extends Plant

func _ready():
	item_slots = [
		PlantItemSlot.new(false, true, 500, [ItemTypes.WATER], false)
	]

func produce():
	.produce()
	item_slots[0].add_items(5, ItemTypes.WATER)
