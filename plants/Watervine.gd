extends Plant

func _ready():
	item_slots.append(PlantItemSlot.new(true, false, 1000, [ItemType.WATER]))
