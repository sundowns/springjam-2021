extends Spatial
class_name PipeNode

onready var pipe_build_indicators = $PipeBuildIndicators

var network_master: Node = null

func set_parent_network(network_master_node: Node):
	network_master = network_master_node

func _on_selected():
	pipe_build_indicators.visible = false
	
func _on_deselected():
	pipe_build_indicators.visible = true

func calculate_and_show_placeable_directions():
	assert("not yet implemented - copy from pipenetwork...")
	pass
