extends Control

const max_value: int = 9999999

onready var water = $HBoxContainer/Water
onready var seeds = $HBoxContainer/Seeds
onready var sunshine = $HBoxContainer/Sunshine

# TODO: trigger this from wallet plant when it exists

func _on_wallet_update(water_count: int, seed_count: int, sunshine_count: int):
	water.set_value(water_count)
	seeds.set_value(seed_count)
	sunshine.set_value(sunshine_count)
