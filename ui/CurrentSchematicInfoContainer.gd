extends Control

onready var water_cost_label: Label = $HBoxContainer/WaterCost/Label
onready var seed_cost_label: Label = $HBoxContainer/SeedCost/Label
onready var sunshine_cost_label: Label = $HBoxContainer/SunshineCost/Label
onready var description: Label = $HBoxContainer/Description
onready var plant_name_label: Label = $Control/PlantName

export(Color) var unaffordable_text_colour: Color
export(Color) var affordable_text_colour: Color
export(Color) var shown_colour: Color

var plant_index: int = 0

func _ready():
# warning-ignore:return_value_discarded
	PlantCosts.connect("wallet_values_updated", self, "update_plant_affordability")

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
			plant_name_label.text = "Pipe Network"
		1: # Watervine
			description.text = "Produces water"
			water_cost_label.text = String(PlantCosts.costs["watervine"].water)
			seed_cost_label.text = String(PlantCosts.costs["watervine"].seeds)
			sunshine_cost_label.text = String(PlantCosts.costs["watervine"].sunshine)
			plant_name_label.text = "Watervine"
		2: # Seedmother
			description.text = "Produces seeds"
			water_cost_label.text = String(PlantCosts.costs["seedmother"].water)
			seed_cost_label.text = String(PlantCosts.costs["seedmother"].seeds)
			sunshine_cost_label.text = String(PlantCosts.costs["seedmother"].sunshine)
			plant_name_label.text = "Seedmother"
		3: # Sunflower
			description.text = "Produces sunshine"
			water_cost_label.text = String(PlantCosts.costs["sunflower"].water)
			seed_cost_label.text = String(PlantCosts.costs["sunflower"].seeds)
			sunshine_cost_label.text = String(PlantCosts.costs["sunflower"].sunshine)
			plant_name_label.text = "Sunflower"
		4: # Incubator
			description.text = "Refines sunshine"
			water_cost_label.text = String(PlantCosts.costs["incubator"].water)
			seed_cost_label.text = String(PlantCosts.costs["incubator"].seeds)
			sunshine_cost_label.text = String(PlantCosts.costs["incubator"].sunshine)
			plant_name_label.text = "Sunshine Incubator"
	update_plant_affordability()

func update_plant_affordability():
	var affordability: Dictionary
	match plant_index:
		0: # Pipe
			affordability = PlantCosts.check_currencies("pipe")
		1: # Watervine
			affordability = PlantCosts.check_currencies("watervine")
		2: # Seedmother
			affordability = PlantCosts.check_currencies("seedmother")
		3: # Sunflower
			affordability = PlantCosts.check_currencies("sunflower")
		4: # Incubator
			affordability = PlantCosts.check_currencies("incubator")
	for key in affordability:
		if key == "overall":
			continue
		match key:
			"water":
				if affordability[key]:
					water_cost_label.modulate = affordable_text_colour
				else:
					water_cost_label.modulate = unaffordable_text_colour
			"seeds":
				if affordability[key]:
					seed_cost_label.modulate = affordable_text_colour
				else:
					seed_cost_label.modulate = unaffordable_text_colour
			"sunshine":
				if affordability[key]:
					sunshine_cost_label.modulate = affordable_text_colour
				else:
					sunshine_cost_label.modulate = unaffordable_text_colour
