extends Control

onready var bg: ColorRect = $ColorRect

onready var water_cost_label: Label = $HBoxContainer/WaterCost/Label
onready var seed_cost_label: Label = $HBoxContainer/SeedCost/Label
onready var sunshine_cost_label: Label = $HBoxContainer/SunshineCost/Label
onready var description: Label = $Description

export(Color) var hidden_colour: Color
export(Color) var shown_colour: Color

var plant_index: int = 0

func _ready():
	bg.modulate = shown_colour

func show_plant(_plant_index: int):
	modulate = shown_colour
	plant_index = _plant_index
	update_plant_info()

func hide_plant():
	modulate.a = 0.0
	update_plant_info()

func update_plant_info():
	match plant_index:
		0: # Pipe
			description.text = "Transports produce"
			water_cost_label.text = String(PlantCosts.costs["pipe"].water)
			seed_cost_label.text = String(PlantCosts.costs["pipe"].seeds)
			sunshine_cost_label.text = String(PlantCosts.costs["pipe"].sunshine)
		1: # Watervine
			description.text = "Produces water"
			water_cost_label.text = String(PlantCosts.costs["watervine"].water)
			seed_cost_label.text = String(PlantCosts.costs["watervine"].seeds)
			sunshine_cost_label.text = String(PlantCosts.costs["watervine"].sunshine)
		2: # Seedmother
			description.text = "Produces seeds"
			water_cost_label.text = String(PlantCosts.costs["seedmother"].water)
			seed_cost_label.text = String(PlantCosts.costs["seedmother"].seeds)
			sunshine_cost_label.text = String(PlantCosts.costs["seedmother"].sunshine)
		3: # Sunflower
			description.text = "Produces sunshine"
			water_cost_label.text = String(PlantCosts.costs["sunflower"].water)
			seed_cost_label.text = String(PlantCosts.costs["sunflower"].seeds)
			sunshine_cost_label.text = String(PlantCosts.costs["sunflower"].sunshine)
		4: # Incubator
			description.text = "Refines sunshine"
			water_cost_label.text = String(PlantCosts.costs["incubator"].water)
			seed_cost_label.text = String(PlantCosts.costs["incubator"].seeds)
			sunshine_cost_label.text = String(PlantCosts.costs["incubator"].sunshine)
