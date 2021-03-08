extends Control

export(PackedScene) var build_plants_ui_scene: PackedScene = preload("res://ui/BuildSchematicsHBoxContainer.tscn")
export(PackedScene) var build_pipes_ui_scene: PackedScene = preload("res://ui/BuildPipesHBoxContainer.tscn")

onready var current_ui: HBoxContainer = null
onready var ui_container: Control = $UiContainer 

var current_mode: int = HudModes.BUILD_PLANT setget set_current_mode

func _ready():
	set_current_mode(HudModes.BUILD_PLANT)

func _input(event):
	var plant_selected = false
	match current_mode:
		HudModes.BUILD_PIPES:
			pass
		HudModes.BUILD_PLANT:
			plant_selected = check_for_plant_selection_input(event)
		HudModes.SELECTION:
			current_mode = HudModes.BUILD_PLANT
			plant_selected = check_for_plant_selection_input(event)
	
	if plant_selected:
		Global.emit_signal("schematic_selection_change")

func check_for_plant_selection_input(event):
	var plant_selected = false
	if event.is_action_pressed("plant_1"):
		plant_selected = true
		if current_ui:
			clear_all_selections()
			current_ui.get_child(0).update_selection(true)
	elif event.is_action_pressed("plant_2"):
		plant_selected = true
		if current_ui:
			clear_all_selections()
			current_ui.get_child(1).update_selection(true)
	elif event.is_action_pressed("plant_3"):
		plant_selected = true
		if current_ui:
			clear_all_selections()
			current_ui.get_child(2).update_selection(true)
	elif event.is_action_pressed("plant_4"):
		plant_selected = true
		if current_ui:
			clear_all_selections()
			current_ui.get_child(3).update_selection(true)
	return plant_selected


func set_current_mode(new_mode: int):
	current_mode = new_mode
	for child in ui_container.get_children():
		child.queue_free()
	match current_mode:
		HudModes.BUILD_PLANT, HudModes.SELECTION:
			set_new_ui(build_plants_ui_scene)
		HudModes.BUILD_PIPES:
			set_new_ui(build_pipes_ui_scene)

func set_new_ui(packed_scene: PackedScene):
	var new_ui = packed_scene.instance()
	ui_container.add_child(new_ui)
	current_ui = new_ui

func clear_all_selections():
	for child in current_ui.get_children():
		child.update_selection(false)
