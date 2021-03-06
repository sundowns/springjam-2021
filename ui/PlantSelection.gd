extends Control

onready var schematic_container: HBoxContainer = $HBoxContainer

func _input(event):
	if event.is_action_pressed("plant_1"):
		clear_all_selections()
		schematic_container.get_child(0).update_selection(true)
	elif event.is_action_pressed("plant_2"):
		clear_all_selections()
		schematic_container.get_child(1).update_selection(true)
	elif event.is_action_pressed("plant_3"):
		clear_all_selections()
		schematic_container.get_child(2).update_selection(true)

func clear_all_selections():
	for child in schematic_container.get_children():
		child.update_selection(false)

