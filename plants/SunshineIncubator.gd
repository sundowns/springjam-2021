extends Plant

const sunshine_per_output := 3

func _ready():
	item_slots = [
		PlantItemSlot.new(true, false, 50, [ItemTypes.WATER]), 
		PlantItemSlot.new(true, false, 10, [ItemTypes.SUNSHINE]) 
	]

func produce():
	if item_slots[0].item_count < minimum_producing_water_level:
		produced_this_update = false
	elif item_slots[1].item_count >= sunshine_per_output:
		# If we have 3 sunshine in the tank
		# Spend sunshine
		item_slots[1].remove_items(sunshine_per_output)
		# Spend water
		item_slots[0].remove_items(minimum_producing_water_level)
		# Add win resource
		WinResource.increment()
		produced_this_update = true
	.produce()
