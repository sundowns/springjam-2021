extends Spatial
class_name Plant

export(String) var plant_name: String = ""

onready var production_tick_timer: Timer = $ProductionTickTimer
onready var output_tick_timer: Timer = $OutputTimer
onready var area_casts: Spatial = $AreaCasts
onready var selectable: Selectable = $Selectable
onready var input_pickers: Spatial = $InputPickers
onready var animation_player: AnimationPlayer = $AnimationPlayer

onready var production_sfx: AudioStreamPlayer3D = $ProductionSfx

export(float) var minimum_producing_water_level: float = 0.0
export(float) var production_tick_duration: float = 3.0
export(bool) var io_manageable: bool = true
export(float) var output_tick_duration: float = 2.0
export(int) var resource_output_per_tick: int = 5 

var grid_position: Vector3 = Vector3.ZERO
var item_slots := []
var valid_item_types := {0: false, 1: false, 2: false, 3: false, 4: false}
var produced_this_update := false

var current_io_state = {
	"Up": "None",
	"Down": "None",
	"Left": "None",
	"Right": "None"
}

signal produced_resource
signal slot_data_changed(slot_data)

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
	call_deferred('calculate_valid_item_types')

func calculate_valid_item_types():
	for slot in item_slots:
		if slot.is_input:
			for allowable in slot.allowed_item_types:
				valid_item_types[allowable] = true

func set_grid_placement(_grid_position: Vector3):
	grid_position = _grid_position

func destroy():
	queue_free()

func produce():
	if produced_this_update:
		emit_signal("produced_resource")
		animation_player.play("Produce")
		production_sfx.play()
	production_tick_timer.start(production_tick_duration)

func _on_selected():
	pass

func _on_deselected():
	pass

func update_io_state(new_state: Dictionary):
	current_io_state = new_state
	input_pickers.set_connections(current_io_state)

func _output_timer_tick():
	var output_direction
	for direction in current_io_state:
		if current_io_state[direction] == "Out":
			output_direction = direction
	
	if output_direction:
		for slot in item_slots:
			if slot.is_output:
				var resources: ResourceBundle = slot.remove_items(resource_output_per_tick)
				var left_over := 0
				if resources.count > 0:
#					print("Outputting ", resources.count, " of " , resources.resource_type, " to ", output_direction)
					var node_in_output_direction = area_casts.fetch_direction(output_direction)
					if node_in_output_direction and node_in_output_direction is Area:
						var pipe_node = node_in_output_direction.get_parent()
						if pipe_node is PipeNode:
							var world_position_of_node = pipe_node.global_transform.origin
							var network = pipe_node.network_master
							var base_offset = network.get_offset_for_position(world_position_of_node)
							for i in range(resources.count):
								var resource = create_resource(resources.resource_type)
								if not network.add_resource(resource, base_offset + i * 0.5):
									left_over += 1
					slot.add_items(left_over, resources.resource_type)
				break
	output_tick_timer.start(output_tick_duration)
	emit_signal("slot_data_changed", item_slots)

func create_resource(resource_type: int):
	match resource_type:
		ItemTypes.EMPTY:
			return null
		ItemTypes.WATER:
			return preload("res://resources/WaterResource.tscn").instance()
		ItemTypes.SEED:
			return preload("res://resources/SeedResource.tscn").instance()
		ItemTypes.SUNSHINE:
			return preload("res://resources/SunshineResource.tscn").instance()

func _on_InputPickers_resource_grabbed(resource):
	if valid_item_types[resource.item_type]:
		for slot in item_slots:
			if slot.is_input and resource.item_type in slot.allowed_item_types:
				if slot.item_count < slot.max_item_count:
					slot.add_items(1, resource.item_type)
					resource.picked_up()
					emit_signal("slot_data_changed", item_slots)
					break
