extends Spatial

onready var camera: Camera = $Camera
onready var selection_tool: SelectionTool = $SelectionTool
onready var plants_container: Spatial = $PlantsContainer
onready var world_ray: RayCast = $SelectionTool/WorldRayCast
onready var map: GridMap = $GridMap
onready var builder_bunny: BuilderBunny = $BunnyBuilder

export(PackedScene) var sunflower_schematic_scene: PackedScene
export(PackedScene) var watervine_schematic_scene: PackedScene
export(PackedScene) var seedmother_schematic_scene: PackedScene
export(PackedScene) var pipenetwork_schematic_scene: PackedScene
export(PackedScene) var incubator_schematic_scene: PackedScene

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
var should_recalc_path_connections := false

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
		HudModes.SELECTION:
			if event.is_action_pressed("ui_cancel"):
				deselect_current()
	
	if event.is_action_pressed("destroy"):
		if current_selectable and (current_selectable.parent is Plant or current_selectable.parent is Schematic or current_selectable.parent is PipeNode):
			refund_current_selectable()
			# Delete the whole network cause cbf implementing subdividing networks
			if current_selectable.parent is PipeNode:
				var network = current_selectable.parent.network_master
				for child in network.nodes_container.get_children():
					remove_plant(child)
				network.destroy()
			remove_plant(current_selectable.parent)
			emit_signal("selection_changed", null)
			if current_hud_mode == HudModes.BUILD_PIPES:
				enter_selection_mode()

func refund_current_selectable():
	if current_selectable.parent is Plant:
		PlantCosts.refund(current_selectable.parent.plant_name)
	elif current_selectable.parent is PipeNode:
		PlantCosts.refund("pipe")
	elif current_selectable.parent is Schematic:
		PlantCosts.refund(current_selectable.parent.plant_name)

func remove_plant(node: Node):
	var plant_map_point = map.world_to_map(node.global_transform.origin)
	clear_map_point(plant_map_point)
	node.destroy()

func clear_map_point(point: Vector3):
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
	map.set_cell_item(point.x, point.y, point.z, -1)

func occupy_map_point(point: Vector3):
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
	map.set_cell_item(point.x, point.y, point.z, 32)

func deselect_current():
	if current_selectable and current_hud_mode == HudModes.SELECTION:
		current_selectable.is_selected = false
		current_selectable = null
		emit_signal("selection_changed", null)

func enter_selection_mode(deselect_after: bool = true):
	selection_tool.change_to_selection_cursor()
	selection_tool.set_cursor_colour(select_mode)
	current_hud_mode = HudModes.SELECTION
	emit_signal("mode_changed", current_hud_mode)
	if deselect_after:
		deselect_current()

func enter_build_plants_mode():
	deselect_current()
	current_hud_mode = HudModes.BUILD_PLANT
	emit_signal("mode_changed", current_hud_mode)
	selection_tool.change_to_build_cursor()

func enter_build_pipes_mode():
	current_hud_mode = HudModes.BUILD_PIPES
	emit_signal("mode_changed", current_hud_mode)

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
		if should_recalc_path_connections:
			calc_current_pipe_node_connections()
		
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
				selection_tool.set_build_validity(true)
#				selection_tool.set_cursor_colour(valid_selection)
				can_build = true
			else:
				selection_tool.set_build_validity(false)
#				selection_tool.set_cursor_colour(invalid_selection)
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
						var can_afford := false
						match selection_tool.selection_index:
							0:
								can_afford = PlantCosts.can_afford("pipe")
							1:
								can_afford = PlantCosts.can_afford("watervine")
							2:
								can_afford = PlantCosts.can_afford("seedmother")
							3:
								can_afford = PlantCosts.can_afford("sunflower")
							4:
								can_afford = PlantCosts.can_afford("incubator")
						if can_afford:
							place_schematic(selection_tool.selection_index)
				HudModes.BUILD_PIPES:
					var pipe_placed := false
#					print("tile ", tile,  " | curr point: ", map_point, " | valids: ",  current_valid_pipe_locations)
					if map_point in current_valid_pipe_locations and tile == -1:
						var selected_plant = current_selectable.parent
						if selected_plant is PipeNode:
							# To is already defined, but not from. Place new node IN FRONT
							if selected_plant.to and not selected_plant.from:
								var new_node = selected_plant.network_master.add_node(selection_position, false)
								selected_plant.from = new_node
								new_node.to = selected_plant
								select_new_thing(new_node.selectable)
								pipe_placed = true
							else: # Otherwise, put it behind existing node
								var new_node = selected_plant.network_master.add_node(selection_position)
								selected_plant.to = new_node
								new_node.from = selected_plant
								select_new_thing(new_node.selectable)
								pipe_placed = true
							occupy_map_point(map_point)
					else:
						var selectable = selection_tool.get_selectable(selection_position + Vector3.UP * 20, Vector3.DOWN * 1000)
						if selectable and selectable != current_selectable:
							if current_selectable.parent is PipeNode:
								current_selectable.parent.update_placeable_indicators_visibility()
							
							select_new_thing(selectable)
							if selectable.parent is PipeNode:
								selectable.parent.update_placeable_indicators_visibility()
					if pipe_placed:
						should_recalc_path_connections = true
				HudModes.SELECTION:
					var selectable = selection_tool.get_selectable(selection_position + Vector3.UP * 20, Vector3.DOWN * 1000)
					select_new_thing(selectable)
					

func calc_current_pipe_node_connections():
	should_recalc_path_connections = false
	if current_selectable and current_selectable.parent is PipeNode:
		current_valid_pipe_locations = find_and_show_current_pipe_connections()

func select_new_thing(selectable: Selectable):
	if selectable:
		var owning_entity = selectable.parent
		if current_selectable:
			current_selectable.is_selected = false
		selectable.is_selected = true
		current_selectable = selectable
		should_recalc_path_connections = true
		emit_signal("selection_changed", selectable)
		if current_hud_mode == HudModes.BUILD_PIPES:
			if not owning_entity is PipeNode:
				enter_selection_mode()
				return
		if current_hud_mode == HudModes.SELECTION:
			if owning_entity is PipeNode:
				enter_build_pipes_mode()
				return

func place_schematic(id):
	var new_schematic: Schematic
	var select_new_schematic := false
	match id:
		0:
			new_schematic = pipenetwork_schematic_scene.instance()
			select_new_schematic = true
			PlantCosts.purchase("pipe")
		1:
			new_schematic = watervine_schematic_scene.instance()
			PlantCosts.purchase("watervine")
		2:
			new_schematic = seedmother_schematic_scene.instance()
			PlantCosts.purchase("seedmother")
		3:
			new_schematic = sunflower_schematic_scene.instance()
			PlantCosts.purchase("sunflower")
		4:
			new_schematic = incubator_schematic_scene.instance()
			PlantCosts.purchase("incubator")
		_:
			return
	
	builder_bunny.wake_if_idle()
	
	plants_container.add_child(new_schematic)
	new_schematic.global_transform.origin = selection_position
# warning-ignore:return_value_discarded
	new_schematic.connect("build_complete", self, "_on_schematic_build_complete", [], CONNECT_DEFERRED)
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
	occupy_map_point(map_point)
	if select_new_schematic:
		select_new_thing(new_schematic.selectable)
		enter_selection_mode(false)

func _on_schematic_build_complete(new_plant: Plant, was_selected: bool):
	var to_select = new_plant.selectable
	if new_plant is PipeNetwork:
		# If it's a network finishing building, get the first node instead
		to_select = new_plant.nodes_container.get_child(0).selectable
	if was_selected:
		select_new_thing(to_select)
		

func _on_BunnyBuilder_request_new_target(current_position: Vector3):
	var closest: Schematic
	var closest_distance: float = INF
	for plant in plants_container.get_children():
		if plant is Schematic:
			var distance = current_position.distance_to(plant.global_transform.origin)
			if distance < closest_distance:
				closest = plant
				closest_distance = distance
	if closest != null:
		builder_bunny._on_target_acquired(closest)
	else:
		builder_bunny.queue_bunny_request()
