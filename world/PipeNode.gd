extends Spatial
class_name PipeNode

onready var pipe_build_indicators = $PipeBuildIndicators
onready var area_casts = $AreaCasts
onready var selectable: Selectable = $Selectable
onready var mesh_instance: MeshInstance = $MeshInstance

var initial_mesh_instance_rotation: Vector3 = Vector3.ZERO

onready var pipe_meshes = {
	"straight": {"resource": preload("res://assets/plant_meshes/pipenode_straight.tres"), "scale": Vector3(2,1,1), "rotation": Vector3(0,90,0)},
	"end_to": {"resource": preload("res://assets/plant_meshes/pipenode_end.tres"), "scale": Vector3(2,1,1), "rotation": Vector3(0,-90,0)},
	"end_from": {"resource": preload("res://assets/plant_meshes/pipenode_end.tres"), "scale": Vector3(2,1,1), "rotation": Vector3(0,-90,0)},
	"corner": {"resource": preload("res://assets/plant_meshes/pipenode_corner.tres"), "scale": Vector3(1,1,1), "rotation": Vector3(0,0,0)},
}

var to: PipeNode setget set_to
var from: PipeNode setget set_from

var network_master: Node = null

func _ready():
	initial_mesh_instance_rotation = mesh_instance.rotation_degrees

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
	to = node
	update_mesh()

func set_from(node: PipeNode):
	from = node
	update_mesh()

func update_mesh():
	if from and to:
		var towards_from = from.global_transform.origin - global_transform.origin
		var towards_to = to.global_transform.origin - global_transform.origin
		var to_from_difference = towards_from + towards_to
		if to_from_difference.is_equal_approx(Vector3.ZERO):
			# Straight ahead
			mesh_instance.mesh = pipe_meshes["straight"].resource
			mesh_instance.scale = pipe_meshes["straight"].scale
			look_at(to.global_transform.origin, Vector3.UP)
			mesh_instance.rotation_degrees = initial_mesh_instance_rotation + pipe_meshes["straight"].rotation
		else:
			mesh_instance.mesh = pipe_meshes["corner"].resource
			mesh_instance.scale = pipe_meshes["corner"].scale
			
			var occupied = {
				"Up": false,
				"Down": false,
				"Left": false,
				"Right": false
			}
			
			# Fill up relative occupancy dict with from
			if towards_from.z == 0:
				# Left/right
				if towards_from.x < 0:
					occupied["Left"] = true
				else:
					occupied["Right"] = true
			elif towards_from.x == 0:
				# Up/down
				if towards_from.z < 0:
					occupied["Up"] = true
				else:
					occupied["Down"] = true
			# Fill up relative occupancy dict with to
			if towards_to.z == 0:
				# Left/right
				if towards_to.x < 0:
					occupied["Left"] = true
				else:
					occupied["Right"] = true
			elif towards_to.x == 0:
				# Up/down
				if towards_to.z < 0:
					occupied["Up"] = true
				else:
					occupied["Down"] = true
			
			if occupied["Up"] and occupied["Right"]:
#				print('up & right')
				mesh_instance.rotation_degrees = initial_mesh_instance_rotation + Vector3(0,0,0)
			if occupied["Up"] and occupied["Left"]:
#				print('up & left')
				mesh_instance.rotation_degrees = initial_mesh_instance_rotation + Vector3(0,90,0)
			if occupied["Down"] and occupied["Right"]:
#				print('down & right')
				mesh_instance.rotation_degrees = initial_mesh_instance_rotation + Vector3(0,0,0)
			if occupied["Down"] and occupied["Left"]:
#				print('down & left')
				mesh_instance.rotation_degrees = initial_mesh_instance_rotation + Vector3(0,90,0)
			print(mesh_instance.rotation_degrees)
		
	else:
		if from:
			mesh_instance.mesh = pipe_meshes["end_from"].resource
			mesh_instance.scale = pipe_meshes["end_from"].scale
			look_at(from.global_transform.origin, Vector3.UP)
			mesh_instance.rotation_degrees = initial_mesh_instance_rotation + pipe_meshes["end_from"].rotation
		elif to:
			mesh_instance.mesh = pipe_meshes["end_to"].resource
			mesh_instance.scale = pipe_meshes["end_to"].scale
			look_at(to.global_transform.origin, Vector3.UP)
			mesh_instance.rotation_degrees = initial_mesh_instance_rotation + pipe_meshes["end_to"].rotation

