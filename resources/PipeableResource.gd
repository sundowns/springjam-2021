extends PathFollow
class_name PipeableResource

signal picked_up

# This is just copied from the global enum cause I can use local ones as an export type for some reason
enum _ItemTypes {
	EMPTY = 0,
	SUNSHINE = 1,
	WATER = 2,
	SEED = 3
}

export(_ItemTypes) var item_type

func move(network_speed: float, delta: float):
	set_offset(offset + network_speed * delta)

func adjust_offset(delta_offset: float):
	set_offset(offset + delta_offset)

func picked_up():
	emit_signal("picked_up")
	queue_free()
