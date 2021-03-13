extends Node

export(String) var resource_name = "spirit"

const AMOUNT_TO_WIN := 50.0
var current_amount := 0.0

var has_won = false

signal game_complete
signal win_resource_amount_update(amount)

func increment():
	current_amount += 1
	emit_signal("win_resource_amount_update", current_amount)
	if not has_won and current_amount >= AMOUNT_TO_WIN:
		victory()

func victory():
	has_won = true
	emit_signal("game_complete")
