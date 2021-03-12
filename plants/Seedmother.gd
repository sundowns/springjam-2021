extends Plant

func _ready():
	item_slots = [
		PlantItemSlot.new(true, false, 20, [ItemTypes.WATER]),
		PlantItemSlot.new(false, true, 10, [ItemTypes.SEED])
	]

func produce():
	.produce()
	print(item_slots[0].item_count < minimum_producing_water_level)
	if item_slots[0].item_count < minimum_producing_water_level:
		return
	# Create seed
	item_slots[1].add_items(1, ItemTypes.SEED)
	# Spend water
	item_slots[0].remove_items(minimum_producing_water_level)
