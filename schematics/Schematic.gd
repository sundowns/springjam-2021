extends Spatial
class_name Schematic

export(PackedScene) var scene: PackedScene
export(float) var build_time := 5.0

onready var tween: Tween = $BuildTween
onready var build_timer: Timer = $BuildTimer
onready var mesh_instance: MeshInstance = $MeshInstance
onready var particles: Particles = $BuildingParticles

func _ready():
	particles.emitting = true 
	mesh_instance.material_override = mesh_instance.material_override.duplicate()
# warning-ignore:return_value_discarded
	tween.interpolate_property(mesh_instance.material_override, "albedo_color:a", 0.0, 0.3, build_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
# warning-ignore:return_value_discarded
	tween.start()
	build_timer.start(build_time)
	yield(get_tree().create_timer(build_time - 2.0), "timeout")
	particles.emitting = false

func _on_BuildTimer_timeout():
	spawn_plant()

func spawn_plant():
	build_timer.disconnect("timeout", self, "_on_BuildTimer_timeout")
	var new_plant = scene.instance()
	get_parent().add_child(new_plant)
	new_plant.global_transform.origin = global_transform.origin
	queue_free()

func destroy():
	queue_free()
