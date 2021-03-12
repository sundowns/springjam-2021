extends Spatial
class_name Plant

onready var production_tick_timer: Timer = $ProductionTickTimer
onready var output_tick_timer: Timer = $OutputTimer
onready var area_casts: Spatial = $AreaCasts
onready var selectable: Selectable = $Selectable

export(float) var minimum_producing_water_level: float = 0.0
export(float) var production_tick_duration: float = 3.0
export(bool) var io_manageable: bool = true
export(float) var output_tick_duration: float = 2.0
export(int) var resource_output_per_tick: int = 5 

var grid_position: Vector3 = Vector3.ZERO
var item_slots = []

var current_io_state = {
	"Up": "None",
	"Down": "None",
	"Left": "None",
	"Right": "None"
}

signal produced_resource

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
		current_item_type = ItemTypes.EMPTY
		item_count = 0
		allowed_item_types = _allowed_item_types
		if start_full:
			item_count = max_item_count
	func add_items(item_delta: int, item_type: int):
		if item_count == 0:
			current_item_type = item_type
		if current_item_type == item_type:
# warning-ignore:narrowing_conversion
			item_count = min(item_count + item_delta, max_item_count)
		else:
			push_warning("Tried to append incorrect resource type to slot (Plant.add_items)")
	func remove_items(item_delta: int) -> ResourceBundle:
		var items_to_remove = min(item_delta, item_count)
# warning-ignore:narrowing_conversion
		item_count = max(item_count - items_to_remove, 0)
		return ResourceBundle.new(items_to_remove, current_item_type)
	func empty():
		item_count = 0
	func allows(item_type: int) -> bool:
		var allowed = false
		for allowed_type in allowed_item_types:
			if item_type == allowed_type:
				allowed = true
				break
		return allowed

class ResourceBundle:
	var count: int
	var resource_type: int
	func _init(_count: int, _resource_type: int):
		count = _count
		resource_type = _resource_type

func _ready():
	if production_tick_duration > 0:
		production_tick_timer.start(production_tick_duration)
	if output_tick_duration > 0:
		output_tick_timer.start(output_tick_duration)

func set_grid_placement(_grid_position: Vector3):
	grid_position = _grid_position

func destroy():
	queue_free()

func produce():
	emit_signal("produced_resource")
	production_tick_timer.start(production_tick_duration)

func _on_selected():
	pass

func _on_deselected():
	pass

func update_io_state(new_state: Dictionary):
	current_io_state = new_state

func _output_timer_tick():
	output_tick_timer.start(output_tick_duration)
