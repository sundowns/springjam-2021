extends Spatial
class_name Plant

onready var selected_particles: Particles = $SelectedParticles
onready var production_tick_timer: Timer = $ProductionTickTimer

export(float) var minimum_producing_water_level: float = 0.0
export(float) var production_tick_duration: float = 3.0

var grid_position: Vector3 = Vector3.ZERO
var is_selected: bool = false setget set_selection
var item_slots = []

signal produced_resource

enum ItemType {
	EMPTY = 0,
	SUNSHINE = 1,
	WATER = 2,
	SEED = 3
}

class PlantItemSlot:
	var is_input: bool
	var is_output: bool
	var max_item_count: int
	var current_item_type: int
	var item_count: int
	var allowed_item_types: Array
	func _init(_is_input: bool, _is_output: bool, _max_item_count: int, _allowed_item_types: Array, start_full: bool = false):
		is_input = _is_input
		is_output = _is_output
		max_item_count = _max_item_count
		current_item_type = ItemType.EMPTY
		item_count = 0
		allowed_item_types = _allowed_item_types
		if start_full:
			item_count = max_item_count
	func add_items(item_delta: int):
# warning-ignore:narrowing_conversion
		item_count = min(item_count + item_delta, max_item_count)
	func remove_items(item_delta: int):
# warning-ignore:narrowing_conversion
		item_count = max(item_count - item_delta, 0)
	func empty():
		item_count = 0
	func allows(item_type: int) -> bool:
		var allowed = false
		for allowed_type in allowed_item_types:
			if item_type == allowed_type:
				allowed = true
				break
		return allowed

func _ready():
	if production_tick_duration > 0:
		production_tick_timer.start(production_tick_duration)

func set_grid_placement(_grid_position: Vector3):
	grid_position = _grid_position

func set_selection(new_status: bool):
	is_selected = new_status
	selected_particles.emitting = is_selected

func destroy():
	queue_free()

func produce():
	emit_signal("produced_resource")
	production_tick_timer.start(production_tick_duration)
