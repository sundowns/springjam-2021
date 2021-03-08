extends Spatial

export(SpatialMaterial) var valid_material = preload("res://materials/valid_pipe_indicator.tres")
export(SpatialMaterial) var invalid_material = preload("res://materials/invalid_pipe_indicator.tres")

func set_all_invalid():
	for child in get_children():
		child.material_override = invalid_material

func set_all_valid():
	for child in get_children():
		child.material_override = valid_material

func set_single_valid(key: String):
	var child = find_node(key, false)
	if child:
		child.material_override = valid_material
	else:
		push_warning("Failed to find pipe build indicator by name, something probs up...")

func set_single_invalid(key: String):
	var child = find_node(key, false)
	if child:
		child.material_override = invalid_material
	else:
		push_warning("Failed to find pipe build indicator by name, something probs up...")
