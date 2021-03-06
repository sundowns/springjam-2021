extends Spatial

onready var camera: Camera = $Camera
onready var selection_tool: MeshInstance = $SelectionTool/MeshInstance
onready var plants_container: Spatial = $PlantsContainer
onready var ray: RayCast = $SelectionTool/RayCast
onready var map: GridMap = $GridMap

export(PackedScene) var sunflower_schematic_scene: PackedScene

export(Color, RGB) var valid_selection: Color
export(Color, RGB) var invalid_selection: Color

var selection_position: Vector3 = Vector3.ZERO
var in_menu := false
var can_build := false
var mouse_pos: Vector2
var map_point: Vector3
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
		
		map_point = map.world_to_map(ray.get_collision_point())
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
		var tile = map.get_cell_item(map_point.x, map_point.y, map_point.z) 
#		print(tile)
		
		# Its an empty tile (need to make a flat blank, empty tile in index 0 of the meshlib)
		if tile == -1:
			selection_tool.get_surface_material(0).set_shader_param("albedo", valid_selection)
			can_build = true
		else:
			selection_tool.get_surface_material(0).set_shader_param("albedo", invalid_selection)
			can_build = false
		
		# Move selection tool mesh
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
		selection_position = map.map_to_world(map_point.x, map_point.y, map_point.z)
		selection_tool.global_transform.origin = selection_position
		
		if Input.is_action_just_pressed("build") and can_build:
			place_schematic(0)

func place_schematic(id):
	match id:
		0:
			var new_plant = sunflower_schematic_scene.instance()
			plants_container.add_child(new_plant)
			new_plant.global_transform.origin = selection_position
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
			map.set_cell_item(map_point.x, map_point.y, map_point.z, 1)
