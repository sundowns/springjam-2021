extends Spatial
class_name SelectionTool

onready var mesh_instance: MeshInstance = $MeshInstance
onready var selection_ray: RayCast = $SelectionRayCast

export(int) var schematics_count: int = 4

export(Mesh) var build_cursor_mesh: Mesh
export(Mesh) var selection_cursor_mesh: Mesh

var selection_index: int = 0

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

func change_to_selection_cursor():
	mesh_instance.mesh = selection_cursor_mesh

func change_to_build_cursor():
	mesh_instance.mesh = build_cursor_mesh

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
	
