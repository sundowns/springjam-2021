extends Spatial

export(Array, PackedScene) var schematics = [] 

var selection_index: int = 0

func _input(event):
	if event.is_action_pressed("plant_1"):
		selection_index = 0
	elif event.is_action_pressed("plant_2"):
		selection_index = 1
	elif event.is_action_pressed("plant_3"):
		selection_index = 2
	elif event.is_action_pressed("plant_4"):
		selection_index = 3
	elif event.is_action_pressed("plant_5"):
		selection_index = 4
	else:
		return
# warning-ignore:narrowing_conversion
	selection_index = min(schematics.size() - 1, selection_index)
	print(selection_index)
