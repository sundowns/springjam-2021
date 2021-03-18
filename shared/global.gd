extends Node

# warning-ignore:unused_signal
signal schematic_selection_change(from_build_pipes)

signal first_pipe_placed
var has_first_pipe_been_placed := false

signal first_pipe_built
var has_first_pipe_been_built := false

signal first_watervine_built
var has_first_watervine_been_built := false

signal first_seedmother_built
var has_first_seedmother_been_built := false

signal first_sunflower_built
var has_first_sunflower_been_built := false

signal first_incubator_built
var has_first_incubator_been_built := false

func pipe_placed():
	if not has_first_pipe_been_placed:
		emit_signal("first_pipe_placed")
		has_first_pipe_been_placed = true

func pipe_built():
	if not has_first_pipe_been_built:
		emit_signal("first_pipe_built")
		has_first_pipe_been_built = true

func watervine_built():
	if not has_first_watervine_been_built:
		emit_signal("first_watervine_built")
		has_first_watervine_been_built = true

func seedmother_built():
	if not has_first_seedmother_been_built:
		emit_signal("first_seedmother_built")
		has_first_seedmother_been_built = true

func sunflower_built():
	if not has_first_sunflower_been_built:
		emit_signal("first_sunflower_built")
		has_first_sunflower_been_built = true

func incubator_built():
	if not has_first_incubator_been_built:
		emit_signal("first_incubator_built")
		has_first_incubator_been_built = true
