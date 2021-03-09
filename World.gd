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
var current_hud_mode: int
const ray_length = 1000

var current_selectable: Selectable
var current_valid_pipe_locations: Array = []

signal mode_changed(hud_mode)
signal selection_changed(selected_node)

func _ready():
# warning-ignore:return_value_discarded
	Global.connect("schematic_selection_change", self, "_on_schematic_selection_change")
	current_hud_mode = HudModes.SELECTION
	selection_tool.change_to_selection_cursor()
	selection_tool.set_cursor_colour(select_mode)

func place_building(building: Plant, grid_indices: Vector3):
	building.set_grid_placement(grid_indices)

func _input(event):
	match current_hud_mode:
		HudModes.BUILD_PLANT:
			if event.is_action_pressed("ui_cancel"):
				enter_selection_mode()
		HudModes.BUILD_PIPES:
			if event.is_action_pressed("ui_cancel"):
				enter_selection_mode()
			# TODO: Delete
			if event.is_action_pressed("ui_page_up"):
				var new_resource = preload("res://resources/WaterResource.tscn").instance()
				var network = current_selectable.parent.network_master
				network.add_resource(new_resource, 0)
		HudModes.SELECTION:
			pass
		
	if event.is_action_pressed("destroy"):
		if current_selectable and (current_selectable.parent is Plant or current_selectable.parent is Schematic or current_selectable.parent is PipeNode):
			current_selectable.parent.destroy()
			var plant_map_point = map.world_to_map(current_selectable.parent.global_transform.origin)
			clear_map_point(plant_map_point)
			if current_hud_mode == HudModes.BUILD_PIPES:
				enter_selection_mode()

func clear_map_point(point: Vector3):
	map.set_cell_item(point.x, point.y, point.z, -1)

func occupy_map_point(point: Vector3):
	map.set_cell_item(point.x, point.y, point.z, 32)

func deselect_current():
	if current_selectable and current_hud_mode == HudModes.SELECTION:
		current_selectable.is_selected = false
		current_selectable = null

func enter_selection_mode():
	selection_tool.change_to_selection_cursor()
	selection_tool.set_cursor_colour(select_mode)
	current_hud_mode = HudModes.SELECTION
	emit_signal("mode_changed", current_hud_mode)
	find_and_show_current_pipe_connections()
	deselect_current()

func enter_build_plants_mode():
	deselect_current()
	current_hud_mode = HudModes.BUILD_PLANT
	emit_signal("mode_changed", current_hud_mode)
	selection_tool.change_to_build_cursor()

func enter_build_pipes_mode():
	current_hud_mode = HudModes.BUILD_PIPES
	emit_signal("mode_changed", current_hud_mode)
	# find out the valid placeable map points for pipes (based on our current selection), store it.
	current_valid_pipe_locations = find_and_show_current_pipe_connections()

func find_and_show_current_pipe_connections() -> Array:
	var valid_points_for_pipes = []
	var cast_directions_dictionary: Dictionary
	if current_selectable:
		var parent = current_selectable.parent
		if parent is PipeNode:
			cast_directions_dictionary = parent.calculate_and_show_placeable_directions()
	
		var plant_map_point = map.world_to_map(current_selectable.parent.global_transform.origin)
		for key in cast_directions_dictionary.keys():
			if cast_directions_dictionary[key] == false:
				match key:
					"Up":
						valid_points_for_pipes.append(plant_map_point + Vector3(0, 0, -1))
					"Down":
						valid_points_for_pipes.append(plant_map_point + Vector3(0, 0, 1))
					"Left":
						valid_points_for_pipes.append(plant_map_point + Vector3(-1, 0, 0))
					"Right":
						valid_points_for_pipes.append(plant_map_point + Vector3(1, 0, 0))
	return valid_points_for_pipes

func _on_schematic_selection_change():
	enter_build_plants_mode()

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
		
		if current_hud_mode in [HudModes.BUILD_PIPES, HudModes.BUILD_PLANT]:
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
			match current_hud_mode:
				HudModes.BUILD_PLANT:
					if can_build:
						place_schematic(selection_tool.selection_index)
				HudModes.BUILD_PIPES:
					if map_point in current_valid_pipe_locations:
						var selected_plant = current_selectable.parent
						if selected_plant is PipeNode:
							# To is already defined, but not from. Place new node IN FRONT
							if selected_plant.to and not selected_plant.from:
								var new_node = selected_plant.network_master.add_node(selection_position, false)
								selected_plant.from = new_node
								new_node.to = selected_plant
								select_new_thing(new_node.selectable)
							else: # Otherwise, put it behind existing node
								var new_node = selected_plant.network_master.add_node(selection_position)
								selected_plant.to = new_node
								new_node.from = selected_plant
								select_new_thing(new_node.selectable)
							occupy_map_point(map_point)
							current_valid_pipe_locations = find_and_show_current_pipe_connections()
				HudModes.SELECTION:
					var selectable = selection_tool.get_selectable(selection_position + Vector3.UP * 20, Vector3.DOWN * 1000)
					select_new_thing(selectable)
					

func select_new_thing(selectable: Selectable):
	if selectable:
		var owning_entity = selectable.parent
		if current_selectable:
			current_selectable.is_selected = false
		selectable.is_selected = true
		current_selectable = selectable
		emit_signal("selection_changed", selectable)
		if current_hud_mode == HudModes.SELECTION:
			if owning_entity is PipeNode or owning_entity is PipeNetwork:
				enter_build_pipes_mode()

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
		_:
			return
	
	plants_container.add_child(new_plant)
	new_plant.global_transform.origin = selection_position
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
	occupy_map_point(map_point)

