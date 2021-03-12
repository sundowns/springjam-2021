extends Plant

func _ready():
	item_slots = [
		PlantItemSlot.new(true, false, 50, [ItemTypes.WATER]),
		PlantItemSlot.new(true, false, 20, [ItemTypes.SEED]),
		PlantItemSlot.new(false, true, 10, [ItemTypes.SUNSHINE])
	]

func produce():
	.produce()
	if item_slots[0].item_count < minimum_producing_water_level:
		return
	# If we have 5 seeds in the tank
	if item_slots[1].item_count >= 5:
		# Create sunshine
		item_slots[2].add_items(1, ItemTypes.SUNSHINE)
		# Spend seeds
		item_slots[1].remove_items(5)
		# Spend water
		item_slots[0].remove_items(25)
	else:
		print("sunflower water_level: ", item_slots[0].item_count)
