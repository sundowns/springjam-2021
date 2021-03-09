extends Plant

func _ready():
	item_slots = [
		PlantItemSlot.new(true, false, 200, [ItemTypes.WATER], true),
		PlantItemSlot.new(false, true, 20, [ItemTypes.SEED])
	]

func produce():
	.produce()
	if item_slots[0].item_count < minimum_producing_water_level:
#		print('not enuff water :c')
		return
	# Create seed
	item_slots[1].add_items(1)
	# Spend water
	item_slots[0].remove_items(25)
	print(item_slots[1].item_count, ",",  item_slots[0].item_count)
