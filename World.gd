extends Spatial

onready var camera: Camera = $Camera
onready var selection_tool: SelectionTool = $SelectionTool
onready var plants_container: Spatial = $PlantsContainer
onready var world_ray: RayCast = $SelectionTool/WorldRayCast
onready var map: GridMap = $GridMap

export(PackedScene) var sunflower_schematic_scene: PackedScene
export(PackedScene) var watervine_schematic_scene: PackedScene
export(PackedScene) var seedmother_schematic_scene: PackedScene
export(PackedScene) var pipenetwork_schematic_scene: PackedScene

export(Color, RGB) var valid_selection: Color
export(Color, RGB) var invalid_selection: Color
export(Color, RGB) var select_mode: Color

var selection_position: Vector3 = Vector3.ZERO
var in_menu := false
var can_build := false
var mouse_pos: Vector2
var map_point: Vector3
var in_build_mode := false
const ray_length = 1000

var current_selection: Plant

signal mode_changed(is_build_mode)
signal selection_changed(selected_node)

func _ready():
	in_build_mode = false
	selection_tool.change_to_selection_cursor()
	selection_tool.set_cursor_colour(select_mode)

func place_building(building: Plant, grid_indices: Vector3):
	building.set_grid_placement(grid_indices)

func _input(event):
	if in_build_mode:
		if event.is_action_pressed("build_mode") or event.is_action_pressed("ui_cancel"): # will back out of build mode once esc doesnt close game...
			in_build_mode = false
			selection_tool.change_to_selection_cursor()
			selection_tool.set_cursor_colour(select_mode)
			emit_signal("mode_changed", false)
			return
	else:
		if event.is_action_pressed("build_mode"):
			in_build_mode = true
			selection_tool.change_to_build_cursor()
			emit_signal("mode_changed", true)
			return
		if event.is_action_pressed("destroy"):
			if current_selection:
				current_selection.destroy()
				var plant_map_point = map.world_to_map(current_selection.global_transform.origin)
				map.set_cell_item(plant_map_point.x, plant_map_point.y, plant_map_point.z, -1)

func _physics_process(_delta):
	if !in_menu:
		mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var to = camera.project_ray_normal(mouse_pos) * ray_length
		world_ray.global_transform.origin = from 
		world_ray.cast_to = to
		world_ray.force_raycast_update()
		
		map_point = map.world_to_map(world_ray.get_collision_point())
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
		var tile = map.get_cell_item(map_point.x, map_point.y, map_point.z) 
		
		if in_build_mode:
			# Its an empty tile (need to make a flat blank, empty tile in index 0 of the meshlib)
			if tile == -1:
				selection_tool.set_cursor_colour(valid_selection)
				can_build = true
			else:
				selection_tool.set_cursor_colour(invalid_selection)
				can_build = false
		
		# Move selection tool mesh
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
		selection_position = map.map_to_world(map_point.x, map_point.y, map_point.z)
		selection_tool.global_transform.origin = selection_position
		
		if Input.is_action_just_pressed("select"):
			if in_build_mode:
				if can_build:
					place_schematic(selection_tool.selection_index)
			else:
				var plant = selection_tool.select_plant(selection_position + Vector3.UP * 20, Vector3.DOWN * 1000)
				if plant:
					if current_selection:
						current_selection.is_selected = false
					plant.is_selected = true
					current_selection = plant
					emit_signal("selection_changed", plant)
					

func place_schematic(id):
	var new_plant
	match id:
		0:
			new_plant = sunflower_schematic_scene.instance()
		1:
			new_plant = watervine_schematic_scene.instance()
		2:
			new_plant = seedmother_schematic_scene.instance()
		3:
			new_plant = pipenetwork_schematic_scene.instance()
	
	plants_container.add_child(new_plant)
	new_plant.global_transform.origin = selection_position
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
	map.set_cell_item(map_point.x, map_point.y, map_point.z, 32)
