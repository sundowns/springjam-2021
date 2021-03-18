extends Plant

func _ready():
	item_slots = [
		PlantItemSlot.new(true, false, 100, [ItemTypes.WATER]),
		PlantItemSlot.new(true, false, 20, [ItemTypes.SEED]),
		PlantItemSlot.new(false, true, 20, [ItemTypes.SUNSHINE])
	]
	Global.sunflower_built()

func produce():
	if item_slots[0].item_count < minimum_producing_water_level:
		produced_this_update = false
	elif item_slots[1].item_count >= 5:
		# If we have 5 seeds in the tank
		# Create sunshine
		item_slots[2].add_items(1, ItemTypes.SUNSHINE)
		# Spend seeds
		item_slots[1].remove_items(5)
		# Spend water
		item_slots[0].remove_items(minimum_producing_water_level)
		produced_this_update = true
	.produce()
