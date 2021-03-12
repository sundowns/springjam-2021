extends Plant

func _ready():
	item_slots = [
		PlantItemSlot.new(false, true, 500, [ItemTypes.WATER], false)
	]

func produce():
	.produce()
	item_slots[0].add_items(50, ItemTypes.WATER)
#	print('water level: %d' % item_slots[0].item_count)

func _output_timer_tick():
#	print(current_io_state)
	
	for direction in current_io_state:
		if current_io_state[direction] == "Out":
			print("output %s" % direction)
	
	for slot in item_slots:
		if slot.is_output:
			var resources: ResourceBundle = slot.remove_items(resource_output_per_tick)
			print(resources.count, " , ", resources.resource_type)
	
	._output_timer_tick()

#func grab_from_output_slot(count: int):
#
#	for slot in item_slots:
#		if slot.is_output and :
#
#			break
