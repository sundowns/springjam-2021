extends VBoxContainer
class_name ItemSlot

onready var count: Label = $HBoxContainer/Count

export(float) var max_capacity: int = 50

var current_load: int = 0

func _ready():
	set_current_load(0)
	
func set_current_load(value: int):
	current_load = value
	count.text = "x %d" % current_load  
