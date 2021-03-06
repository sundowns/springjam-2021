extends Spatial

export(PackedScene) var scene: PackedScene
export(float) var build_time := 5.0

onready var tween: Tween = $BuildTween
onready var build_timer: Timer = $BuildTimer
onready var mesh_instance: MeshInstance = $MeshInstance
onready var particles: Particles = $BuildingParticles

func _ready():
	particles.emitting = true 
#	tween.interpolate_property(mesh_instance.material_override, "albedo.a")
#	tween.start()
#	(object: Object, property: NodePath, initial_val: Variant, final_val: Variant, duration: float, trans_type: TransitionType = 0, ease_type: EaseType = 2, delay: float = 0
	build_timer.start(build_time)

func _on_BuildTimer_timeout():
	spawn_plant()

func spawn_plant():
	build_timer.disconnect("timeout", self, "_on_BuildTimer_timeout")
	var new_plant = scene.instance()
	get_parent().add_child(new_plant)
	new_plant.global_transform.origin = global_transform.origin
	queue_free()
