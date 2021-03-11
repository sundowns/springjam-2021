extends Spatial
class_name PipeNode

onready var pipe_build_indicators = $PipeBuildIndicators
onready var area_casts = $AreaCasts
onready var selectable: Selectable = $Selectable

var to: PipeNode setget set_to
var from: PipeNode setget set_from

var network_master: Node = null

func set_parent_network(network_master_node: Node):
	network_master = network_master_node

func destroy():
	queue_free()

func _on_selected():
	pipe_build_indicators.visible = true
	update_placeable_indicators_visibility()
	
func _on_deselected():
	pipe_build_indicators.visible = false
	update_placeable_indicators_visibility()

func update_placeable_indicators_visibility():
	if not selectable.is_selected:
		pipe_build_indicators.visible = false
		return
	if from and to:
		pipe_build_indicators.visible = false
	else:
		pipe_build_indicators.visible = true

func calculate_and_show_placeable_directions() -> Dictionary:
	# get a list of whether each area cast is colliding with a plant
	var casts_colliding_map = area_casts.get_status()
	
	# Override if both front and back are already defined
	if from and to:
		return {
			"Up": true,
			"Down": true,
			"Left": true,
			"Right": true
		}
	
	# Update corresponding indicators
	update_indicator("Up", casts_colliding_map)
	update_indicator("Down", casts_colliding_map)
	update_indicator("Left", casts_colliding_map)
	update_indicator("Right", casts_colliding_map)
	return casts_colliding_map

func update_indicator(node_key: String, collision_map: Dictionary):
	if collision_map[node_key]:
		pipe_build_indicators.set_single_invalid(node_key)
	else:
		pipe_build_indicators.set_single_valid(node_key)

func set_to(node: PipeNode):
	look_at(node.global_transform.origin, Vector3.UP)
	to = node

func set_from(node: PipeNode):
	from = node
