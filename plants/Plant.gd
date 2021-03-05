extends Spatial
class_name Plant

export(float) var max_water_level: float = 100.0
export(float) var starting_water_level: float = 50.0
onready var current_water_level: float = max_water_level

var grid_position: Vector3 = Vector3.ZERO

func set_grid_placement(_grid_position: Vector3):
	grid_position = _grid_position
