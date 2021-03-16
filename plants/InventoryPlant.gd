extends Plant

func _ready():
	production_tick_timer.stop()
	output_tick_timer.stop()
	PlantCosts.emit_signal("inventory_plant_ready")
	update_io_state({
		"Up": "In",
		"Down": "In",
		"Left": "In",
		"Right": "In"
	})

func update_io_state(new_state: Dictionary):
	var no_output_states = new_state.duplicate()
	for direction in new_state:
		if new_state[direction] == "Out":
			no_output_states[direction] = "None"
	.update_io_state(no_output_states)

func grabbed_resource(resource):
	match resource.item_type:
		ItemTypes.WATER:
			PlantCosts.update_wallet_values(1, 0, 0)
		ItemTypes.SEED:
			PlantCosts.update_wallet_values(0, 1, 0)
		ItemTypes.SUNSHINE:
			PlantCosts.update_wallet_values(0, 0, 1)
	resource.picked_up()
