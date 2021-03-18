extends Plant

func _ready():
	item_slots = [
		PlantItemSlot.new(false, true, 200, [ItemTypes.WATER], false)
	]
	Global.watervine_built()

func produce():
	item_slots[0].add_items(10, ItemTypes.WATER)
	produced_this_update = true
	.produce()
