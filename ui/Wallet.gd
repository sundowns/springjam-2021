extends Control

const max_value: int = 9999999

onready var water = $HBoxContainer/Water
onready var seeds = $HBoxContainer/Seeds
onready var sunshine = $HBoxContainer/Sunshine

func _ready():
# warning-ignore:return_value_discarded
	PlantCosts.connect("wallet_values_updated", self, "_on_wallet_update")

func _on_wallet_update():
	water.set_value(PlantCosts.wallet["water"])
	seeds.set_value(PlantCosts.wallet["seeds"])
	sunshine.set_value(PlantCosts.wallet["sunshine"])
