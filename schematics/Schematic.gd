extends Spatial
class_name Schematic

export(PackedScene) var scene: PackedScene
export(String) var plant_name: String

onready var tween: Tween = $BuildTween
onready var mesh_instance: MeshInstance = $MeshInstance
onready var particles: Particles = $BuildingParticles
onready var selectable: Selectable = $Selectable

signal build_complete(new_plant, was_selected)

func _ready():
	mesh_instance.material_override = mesh_instance.material_override.duplicate()
	
func start_build(duration: float):
	particles.emitting = true 
# warning-ignore:return_value_discarded
	tween.interpolate_property(mesh_instance.material_override, "albedo_color:a", 0.0, 0.3, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
# warning-ignore:return_value_discarded
	tween.start()

func spawn_plant():
	var new_plant = scene.instance()
	get_parent().add_child(new_plant)
	new_plant.global_transform.origin = global_transform.origin
	emit_signal("build_complete", new_plant, selectable.is_selected)
	queue_free()

func destroy():
	if plant_name == "inventory":
		return
	queue_free()
