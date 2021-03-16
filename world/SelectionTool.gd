extends Spatial
class_name SelectionTool

onready var mesh_instance: MeshInstance = $MeshInstance
onready var selection_ray: RayCast = $SelectionRayCast

export(Color) var valid_build_colour: Color
export(Color) var invalid_build_colour: Color

export(int) var schematics_count: int = 4

export(Mesh) var build_cursor_mesh: Mesh
export(Mesh) var selection_cursor_mesh: Mesh

var selection_index: int = 0
var is_build_cursor := false
var is_selection_cursor := false
var build_placement_valid := false

func _input(event):
	if event.is_action_pressed("plant_1"):
		selection_index = 0
	elif event.is_action_pressed("plant_2"):
		selection_index = 1
	elif event.is_action_pressed("plant_3"):
		selection_index = 2
	elif event.is_action_pressed("plant_4"):
		selection_index = 3
	elif event.is_action_pressed("plant_5"):
		selection_index = 4
	else:
		return
# warning-ignore:narrowing_conversion
	selection_index = min(schematics_count, selection_index)
	check_schematic_buildable()

func change_to_selection_cursor():
	mesh_instance.mesh = selection_cursor_mesh
	is_build_cursor = false
	is_selection_cursor = true

func change_to_build_cursor():
	mesh_instance.mesh = build_cursor_mesh
	is_build_cursor = true
	is_selection_cursor = false

func set_cursor_colour(colour: Color):
	mesh_instance.material_override.set_shader_param("albedo", colour)

func get_selectable(from: Vector3, to: Vector3) -> Selectable:
	selection_ray.global_transform.origin = from
	selection_ray.cast_to = to
	selection_ray.force_raycast_update()
	if selection_ray.is_colliding():
		var selected_object = selection_ray.get_collider().get_parent()
		if selected_object is Selectable:
			return selected_object
		else:
			return null
	else:
		return null

func check_schematic_buildable():
	if not is_build_cursor:
		return
	var plant_name = ""
	match selection_index:
		0:
			plant_name = "pipe"
		1: 
			plant_name = "watervine"
		2:
			plant_name = "seedmother"
		3:
			plant_name = "sunflower"
		4:
			plant_name = "incubator"
		_:
			return
	var can_afford = PlantCosts.can_afford(plant_name)
	if not can_afford:
		set_cursor_colour(invalid_build_colour)

func set_build_validity(new_val: bool):
	build_placement_valid = new_val
	if not build_placement_valid:
		set_cursor_colour(invalid_build_colour)
	else:
		set_cursor_colour(valid_build_colour)
		check_schematic_buildable()
