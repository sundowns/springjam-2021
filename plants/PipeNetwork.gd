extends Plant
class_name PipeNetwork

onready var path: Path = $Path
onready var start_point_mesh: MeshInstance = $StartPointMesh
onready var end_point_mesh: MeshInstance = $EndPointMesh
onready var nodes_container: Spatial = $NodesContainer
onready var path_visualiser: PathFollow = $Path/PathVisualiser

const pipe_node_scene: PackedScene = preload("res://world/PipeNode.tscn")
const capacity_per_cell := 5
const resource_move_speed := 1.5
var capacity := 0
var current_load := 0
var child_is_selected := false

func _ready():
	path.curve = Curve3D.new()
	# We just rely on selecting nodes...
	$Selectable.queue_free()
# warning-ignore:return_value_discarded
	add_node(global_transform.origin)

func set_start(start_point: Vector3):
	path.curve.clear_points()
	path.curve.add_point(start_point)
	capacity = path.curve.get_point_count() * capacity_per_cell
	
	start_point_mesh.visible = true
	start_point_mesh.global_transform.origin = start_point
	end_point_mesh.visible = false

func add_node(position: Vector3, add_to_back: bool = true, generate_new_curve: bool = true) -> PipeNode:
	var new_node: PipeNode = pipe_node_scene.instance()
	new_node.set_parent_network(self)
	nodes_container.add_child(new_node)
	if not add_to_back:
		nodes_container.move_child(new_node, 0)
		adjust_all_resource_offsets(2)
	new_node.global_transform.origin = position
	capacity += capacity_per_cell
	if generate_new_curve:
		generate_curve_from_nodes()
	return new_node

func adjust_all_resource_offsets(offset: float):
	for resource in path.get_children():
		if resource is PipeableResource:
			resource.adjust_offset(offset)

func generate_curve_from_nodes():
	# Clear existing points on the curve
	path.curve.clear_points()
	# Populate curve with position of nodes
	for child in nodes_container.get_children():
		if child is PipeNode:
			path.curve.add_point(child.global_transform.origin - global_transform.origin)
	var path_length = path.curve.get_point_count()
	capacity = path_length * capacity_per_cell
	if path_length > 0:
		start_point_mesh.global_transform.origin = path.curve.get_point_position(0)
		start_point_mesh.visible = true
	else: 
		start_point_mesh.visible = false
	if path_length > 1:
		end_point_mesh.global_transform.origin = path.curve.get_point_position(path_length - 1)
		end_point_mesh.visible = true
	else:
		end_point_mesh.visible = false
	evaluate_showing_path_visualiser()

func add_resource(pipeable_resource: PipeableResource, offset: float) -> bool:
	if nodes_container.get_child_count() < 2:
		return false
	if current_load < capacity:
		current_load += 1
		path.add_child(pipeable_resource)
		pipeable_resource.set_offset(offset)
# warning-ignore:return_value_discarded
		pipeable_resource.connect("picked_up", self, "_on_resource_removed", [], CONNECT_DEFERRED)
		return true
	else:
		return false

func _physics_process(delta):
	for child in path.get_children():
		if child is PipeableResource:
			child.move(resource_move_speed, delta)

func get_offset_for_position(world_pos: Vector3) -> float:
	return path.curve.get_closest_offset(to_local(world_pos))

func _on_resource_removed():
	current_load -= 1

func set_pipe_selected(new_value: bool):
	child_is_selected = new_value
	evaluate_showing_path_visualiser()

func evaluate_showing_path_visualiser():
	if child_is_selected and nodes_container.get_child_count() > 1:
		path_visualiser.activate(capacity)
	else:
		path_visualiser.deactivate()
