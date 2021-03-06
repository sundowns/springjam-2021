extends Spatial

export(PackedScene) var scene: PackedScene
export(float) var build_time := 5.0

onready var build_timer: Timer = $BuildTimer

func _ready():
	build_timer.start(build_time)

func _on_BuildTimer_timeout():
	spawn_plant()

func spawn_plant():
	build_timer.disconnect("timeout", self, "_on_BuildTimer_timeout")
	var new_plant = scene.instance()
	get_parent().add_child(new_plant)
	new_plant.global_transform.origin = global_transform.origin
	queue_free()
