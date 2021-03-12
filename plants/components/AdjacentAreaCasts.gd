extends Spatial

const radius := 2.0

export(int, LAYERS_3D_PHYSICS) var collision_mask = 2

const pipe_nodes_collision_mask: int = 8

var cast_shape: BoxShape
var cast_shape_query: PhysicsShapeQueryParameters

func _ready():
	cast_shape = BoxShape.new()
	cast_shape.extents = Vector3(radius/2, radius/2, radius/2)
	cast_shape_query = PhysicsShapeQueryParameters.new()
	cast_shape_query.collide_with_areas = true
	cast_shape_query.collide_with_bodies = false
	cast_shape_query.collision_mask = collision_mask
	cast_shape_query.set_shape(cast_shape)

func get_status() -> Dictionary:
	var result = {}
	var current_game_space := get_world().direct_space_state
	for child in get_children():
		# Check if the area is colliding with anything
		result[child.name] = check_for_collision(child, current_game_space)
	return result

func check_for_collision(query_position: Position3D, current_game_space: PhysicsDirectSpaceState) -> bool:
	cast_shape_query.transform = query_position.global_transform
	cast_shape_query.collision_mask = collision_mask
	var cast_result = current_game_space.intersect_shape(cast_shape_query, 8)
	if cast_result:
		return true
	else:
		return false

func fetch_direction(direction: String) -> Node:
	if has_node(direction):
		var cast_node = get_node(direction)
		# Cast to find what node is in that direction (if any)
		cast_shape_query.transform = cast_node.global_transform
		cast_shape_query.collision_mask = pipe_nodes_collision_mask
		var cast_result = get_world().direct_space_state.intersect_shape(cast_shape_query, 1)
		if cast_result and cast_result[0]:
			return cast_result[0].collider
		else:
			return null
	else: 
		return null
