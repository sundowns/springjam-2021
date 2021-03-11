extends Spatial
class_name BuilderBunny

const move_speed := 5.0
const building_range := 2.0
const rerequest_path_delay := 3.0
export(float) var build_time: float = 3.0

onready var build_timer: Timer = $BuildTimer
onready var rerequest_timer: Timer = $ReRequestTimer
onready var animation_player: AnimationPlayer = $AnimationPlayer

var current_target: Schematic

enum BunnyStates {
	IDLE = 0,
	RUN = 1,
	BUILD = 2
}

var state: int = BunnyStates.IDLE

signal request_new_target(current_position)


func _process(delta):
	match state:
		BunnyStates.IDLE:
			if current_target:
				enter_run_state()
		BunnyStates.RUN:
			if current_target != null:
				var to_target = (current_target.global_transform.origin - global_transform.origin)
				var direction = to_target.normalized()
				if to_target.length() > building_range:
					move(direction, delta)
				else:
					enter_build_state()
			else:
				enter_idle_state()
		BunnyStates.BUILD:
			if current_target == null:
				enter_idle_state()

func enter_build_state():
	build_timer.stop()
	state = BunnyStates.BUILD
	animation_player.play("BuildStart")

func enter_idle_state():
	build_timer.stop()
	state = BunnyStates.IDLE
	animation_player.play("Idle")
	look_for_new_target()

func enter_run_state():
	build_timer.stop()
	state = BunnyStates.RUN
	animation_player.play("Run")
	if not current_target:
		enter_idle_state()
		return
	if current_target.global_transform.origin.distance_to(global_transform.origin) < building_range:
		enter_build_state()
		return

func look_for_new_target():
	emit_signal("request_new_target", global_transform.origin)

func _on_target_acquired(target: Schematic):
	current_target = target
	look_at(current_target.global_transform.origin, Vector3.UP)

func move(direction: Vector3, delta: float):
	global_transform.origin = global_transform.origin + direction * move_speed * delta

func _on_build_start_animation_end():
	if current_target:
		animation_player.play("Build")
		current_target.start_build(build_time)
		build_timer.start(build_time)
	else:
		enter_idle_state()

func _on_BuildTimer_timeout():
	if current_target:
		current_target.spawn_plant()
	enter_idle_state()

func queue_bunny_request():
	rerequest_timer.start(rerequest_path_delay)

func _on_ReRequestTimer_timeout():
	look_for_new_target()

func _on_WakeUpTimer_timeout():
	enter_idle_state()
