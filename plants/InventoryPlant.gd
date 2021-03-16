extends Plant

func _ready():
	production_tick_timer.stop()
	output_tick_timer.stop()

func update_io_state(new_state: Dictionary):
	var no_output_states = new_state.duplicate()
	for direction in new_state:
		if new_state[direction] == "Out":
			no_output_states[direction] = "None"
	.update_io_state(no_output_states)


# TODO: needs to handle inputs differently and pipe them into wallet instead of slots!
