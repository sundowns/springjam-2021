extends Spatial

onready var camera: Camera = $Camera
onready var selection_tool: MeshInstance = $SelectionTool/MeshInstance
onready var ray: RayCast = $SelectionTool/RayCast
onready var map: GridMap = $GridMap

export(Color, RGB) var valid_selection: Color
export(Color, RGB) var invalid_selection: Color

var in_menu := false
var can_build := false
var mouse_pos: Vector2
const ray_length = 1000

func place_building(building: Plant, grid_indices: Vector3):
	building.set_grid_placement(grid_indices)

func _physics_process(_delta):
	if !in_menu:
		mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var to = camera.project_ray_normal(mouse_pos) * ray_length
		ray.global_transform.origin = from 
		ray.cast_to = to
		ray.force_raycast_update()
		
		var map_point = map.world_to_map(ray.get_collision_point())
		var tile = map.get_cell_item(map_point.x, map_point.y, map_point.z) 
		print(map_point)
		
		# Its an empty tile (need to make a flat blank, empty tile in index 0 of the meshlib)
		if tile == 0:
			selection_tool.get_surface_material(0).set_shader_param("albedo", valid_selection)
			can_build = true
		else:
			selection_tool.get_surface_material(0).set_shader_param("albedo", invalid_selection)
			can_build = false
		
		# Move selection tool mesh
		var selection_position = map.map_to_world(map_point.x, map_point.y, map_point.z)
		selection_tool.global_transform.origin = selection_position
