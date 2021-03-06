extends Plant

func _ready():
	item_slots = [
		PlantItemSlot.new(true, false, 500, [ItemType.WATER], false)
	]

func produce():
	.produce()
	item_slots[0].add_items(50)
	print('water level: %d' % item_slots[0].item_count)
