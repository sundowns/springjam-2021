extends Plant

func _ready():
	item_slots = [
		PlantItemSlot.new(true, false, 20, [ItemTypes.WATER]),
		PlantItemSlot.new(false, true, 20, [ItemTypes.SEED])
	]

func produce():
	if item_slots[0].item_count < minimum_producing_water_level:
		produced_this_update = false
	else:
		# Create seed
		item_slots[1].add_items(2, ItemTypes.SEED)
		# Spend water
		item_slots[0].remove_items(minimum_producing_water_level)
		produced_this_update = true
	.produce()
