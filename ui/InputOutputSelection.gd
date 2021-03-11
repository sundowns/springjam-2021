extends Control

var current_selected_plant: Plant

const default_states: Dictionary = {
	"Up": "None",
	"Down": "None",
	"Left": "None",
	"Right": "None"
}
onready var current_selection_state := default_states


func update_selected_plant(selected_plant: Plant):
	current_selected_plant = selected_plant
	if selected_plant:
		current_selection_state = selected_plant.current_io_state
	else:
		current_selection_state = default_states
	update_dropdowns()

func _on_selection_changed(name, selection_name):
	current_selection_state[name] = selection_name
	if current_selected_plant:
		current_selected_plant.update_io_state(current_selection_state)

func update_dropdowns():
	for child in get_children():
		if child is MenuButton:
			child.set_text(current_selection_state[child.name])
