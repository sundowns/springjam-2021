extends Spatial

func get_status() -> Dictionary:
	var result = {}
	for child in get_children():
		# Check if the area is colliding with anything
		result[child.name] = child.get_overlapping_areas().size() > 0
		print(child.name ," , ", result[child.name], " , ", child.get_overlapping_areas().size())
	return result
