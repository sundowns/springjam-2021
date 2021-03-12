extends Spatial

signal resource_grabbed(resource)

# Have plant disable when input slots are full (for performance)
var enabled := true

func set_connections(io_status: Dictionary):
	for direction_key in io_status.keys():
		var picker_area = get_node(direction_key)
		picker_area.get_child(0).disabled = io_status[direction_key] != "In"

func _on_area_entered(area):
	var resource = area.get_parent()
	if resource is PipeableResource:
		emit_signal("resource_grabbed", resource)
	
