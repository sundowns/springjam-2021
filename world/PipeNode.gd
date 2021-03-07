extends Spatial
class_name PipeNode

var network_master: Node = null

func set_parent_network(network_master_node: Node):
	network_master = network_master_node
