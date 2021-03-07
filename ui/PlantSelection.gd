extends Control

onready var schematic_container: HBoxContainer = $HBoxContainer

func _input(event):
	var plant_selected = false
	if event.is_action_pressed("plant_1"):
		plant_selected = true
		clear_all_selections()
		schematic_container.get_child(0).update_selection(true)
	elif event.is_action_pressed("plant_2"):
		plant_selected = true
		clear_all_selections()
		schematic_container.get_child(1).update_selection(true)
	elif event.is_action_pressed("plant_3"):
		plant_selected = true
		clear_all_selections()
		schematic_container.get_child(2).update_selection(true)
	elif event.is_action_pressed("plant_4"):
		plant_selected = true
		clear_all_selections()
		schematic_container.get_child(3).update_selection(true)
	
	if plant_selected:
		Global.emit_signal("schematic_selection_change")
		
#	elif event.is_action_pressed("plant_5"):
#		clear_all_selections()
#		schematic_container.get_child(4).update_selection(true)
#	elif event.is_action_pressed("plant_6"):
#		clear_all_selections()
#		schematic_container.get_child(5).update_selection(true)
#	elif event.is_action_pressed("plant_7"):
#		clear_all_selections()
#		schematic_container.get_child(6).update_selection(true)
#	elif event.is_action_pressed("plant_8"):
#		clear_all_selections()
#		schematic_container.get_child(7).update_selection(true)
	

func clear_all_selections():
	for child in schematic_container.get_children():
		child.update_selection(false)