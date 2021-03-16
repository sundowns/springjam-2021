extends PathFollow

export(float) var speed := 0.1
onready var scaled_speed: float = speed

var is_active := false
var direction := 1

func _ready():
	visible = false

func activate(path_capacity: float):
	scaled_speed = path_capacity *  0.1
	is_active = true
	visible = true

func deactivate():
	is_active = false
	visible = false

func _physics_process(delta):
	if is_active:
		set_offset(offset + delta * scaled_speed * direction)

func set_direction(_direction: int):
	direction = _direction
