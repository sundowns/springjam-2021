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
	if selection_name == "Out":
		# set any other output slots to None first, only support one per plant
		set_outputs_to_none()
	
	current_selection_state[name] = selection_name
	update_dropdowns()
	
	if current_selected_plant:
		current_selected_plant.update_io_state(current_selection_state)

func update_dropdowns():
	for child in get_children():
		if child is MenuButton:
			child.set_text(current_selection_state[child.name])

func set_outputs_to_none():
	for child in get_children():
		if child is MenuButton and child.text == "Out":
			current_selection_state[child.name] = "None"
			child.set_text(current_selection_state[child.name])

