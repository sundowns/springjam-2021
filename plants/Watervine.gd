extends Plant

func _ready():
	item_slots = [
		PlantItemSlot.new(false, true, 500, [ItemTypes.WATER], false)
	]

func produce():
	item_slots[0].add_items(5, ItemTypes.WATER)
	produced_this_update = true
	.produce()
