extends Plant

onready var path: Path = $Path
onready var start_point_mesh: MeshInstance = $StartPointMesh
onready var end_point_mesh: MeshInstance = $EndPointMesh
onready var nodes_container: Spatial = $NodesContainer

const pipe_node_scene: PackedScene = preload("res://world/PipeNode.tscn")
const capacity_per_cell := 3
const resource_move_speed := 2.0
var capacity := 0
var current_load := 0

func _ready():
	generate_curve_from_nodes()

func set_start(start_point: Vector3):
	path.curve.clear_points()
	path.curve.add_point(start_point)
	capacity = path.curve.get_point_count() * capacity_per_cell
	
	start_point_mesh.visible = true
	start_point_mesh.global_transform.origin = start_point
	end_point_mesh.visible = false

func add_node(position: Vector3, add_to_back: bool = true, generate_new_curve: bool = true):
	var new_node: PipeNode = pipe_node_scene.instance()
	new_node.set_parent_network(self)
	add_child(new_node)
	if not add_to_back:
		move_child(new_node, 0)
	new_node.global_transform.origin = position
	capacity += capacity_per_cell
	if generate_new_curve:
		generate_curve_from_nodes()

func generate_curve_from_nodes():
	# Clear existing points on the curve
	path.curve.clear_points()
	# Populate curve with position of nodes
	for child in nodes_container.get_children():
		if child is PipeNode:
			path.curve.add_point(child.global_transform.origin)
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

func insert_resource(pipeable_resource: PipeableResource, offset: float):
	current_load += 1
	path.add_child(pipeable_resource)
	pipeable_resource.set_offset(offset)

func remove_resource():
	current_load -= 1

func _physics_process(delta):
	for child in path.get_children():
		if child is PipeableResource:
			print("moving along pipe...")
			child.set_offset(child.offset + resource_move_speed * delta)
