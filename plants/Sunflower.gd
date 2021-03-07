extends Plant

func _ready():
	item_slots = [
		PlantItemSlot.new(true, false, 200, [ItemType.WATER], false),
		PlantItemSlot.new(true, false, 20, [ItemType.SEED]),
		PlantItemSlot.new(false, true, 10, [ItemType.SUNSHINE])
	]

func produce():
	.produce()
	if item_slots[0].item_count < minimum_producing_water_level:
		print('not enuff water :c')
		return
	# If we have 5 seeds in the tank
	if item_slots[1].item_count >= 5:
		# Create sunshine
		item_slots[2].add_items(1)
		# Spend seeds
		item_slots[1].remove_items(5)
		# TODO: use a different timer for water depreciation?
		item_slots[0].remove_items(25)
	else:
		print("not enuff seeds")
		print(item_slots[0].item_count)
