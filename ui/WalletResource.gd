extends MarginContainer

onready var label = $Control/Count

func set_value(new_value: int):
	label.text = String(new_value)
