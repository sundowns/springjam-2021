extends Node

# warning-ignore:unused_signal
signal schematic_selection_change

signal first_pipe_placed
var has_first_pipe_been_placed := false

func pipe_placed():
	if not has_first_pipe_been_placed:
		emit_signal("first_pipe_placed")
		has_first_pipe_been_placed = true

func _input(_event):
	pass
