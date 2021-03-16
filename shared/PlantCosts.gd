extends Node

var wallet = {
	"water": 0,
	"seeds": 0,
	"sunshine": 0
}

var costs = {
	"pipe": {
		"water": 0,
		"seeds": 0,
		"sunshine": 0
	},
	"watervine": {
		"water": 10,
		"seeds": 0,
		"sunshine": 0
	},
	"seedmother": {
		"water": 20,
		"seeds": 5,
		"sunshine": 0
	},
	"sunflower": {
		"water": 30,
		"seeds": 20,
		"sunshine": 0
	},
	"incubator": {
		"water": 50,
		"seeds": 50,
		"sunshine": 3
	}
}

signal wallet_values_updated

func _ready():
	call_deferred("initialise_wallet")

func initialise_wallet():
	wallet = {
		"water": 20,
		"seeds": 5,
		"sunshine": 0
	}
	emit_signal("wallet_values_updated")

func check_currencies(key: String) -> Dictionary:
	var affordable = {
		"water": false,
		"seeds": false,
		"sunshine": false,
		"overall": true
	}
	
	if costs.has(key):
		var plant_costs = costs[key]
		if wallet["water"] >= plant_costs["water"]:
			affordable["water"] = true
		if wallet["seeds"] >= plant_costs["seeds"]:
			affordable["seeds"] = true
		if wallet["sunshine"] >= plant_costs["sunshine"]:
			affordable["sunshine"] = true
	
	# Check if plant is overall affordable
	for key in affordable:
		if key == "overall":
			continue
		if affordable[key] == false:
			affordable["overall"] = false
			break
	return affordable

func can_afford(key: String) -> bool:
	var is_affordable := true
	if costs.has(key):
		var plant_costs = costs[key]
		if wallet["water"] < plant_costs["water"]:
			is_affordable = false
		if wallet["seeds"] < plant_costs["seeds"]:
			is_affordable = false
		if wallet["sunshine"] < plant_costs["sunshine"]:
			is_affordable = false
	return is_affordable

func update_wallet_values(water_delta: int, seeds_delta: int, sunshine_delta: int):
	wallet["water"] += water_delta
	wallet["seeds"] += seeds_delta
	wallet["sunshine"] += sunshine_delta
	emit_signal("wallet_values_updated")

func refund(plant_key: String):
	if costs.has(plant_key):
		var plant_costs = costs[plant_key]
		update_wallet_values(plant_costs["water"], plant_costs["seeds"], plant_costs["sunshine"])
