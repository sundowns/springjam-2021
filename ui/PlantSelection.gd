extends Control

export(PackedScene) var build_plants_ui_scene: PackedScene = preload("res://ui/BuildSchematicsHBoxContainer.tscn")

onready var current_ui: Control = null
onready var ui_container: ColorRect = $VBoxContainer/UiContainer
onready var current_schematic_container: Control = $VBoxContainer/CurrentSchematicInfoContainer

var current_mode: int = HudModes.SELECTION setget set_current_mode

func _ready():
	set_current_mode(HudModes.BUILD_PLANT)
	set_new_ui(build_plants_ui_scene)

func _input(event):
	var plant_selected = false
	match current_mode:
		HudModes.BUILD_PIPES:
			plant_selected = check_for_plant_selection_input(event)
		HudModes.BUILD_PLANT:
			plant_selected = check_for_plant_selection_input(event)
		HudModes.SELECTION:
			current_mode = HudModes.BUILD_PLANT
			plant_selected = check_for_plant_selection_input(event)
	
	if plant_selected:
		Global.emit_signal("schematic_selection_change", current_mode == HudModes.BUILD_PIPES)

func check_for_plant_selection_input(event):
	var plant_selected = false
	if event.is_action_pressed("plant_1"):
		plant_selected = true
		if current_ui:
			clear_all_selections()
			current_ui.get_child(0).get_child(0).update_selection(true)
			current_schematic_container.show_plant(0)
	elif event.is_action_pressed("plant_2"):
		plant_selected = true
		if current_ui:
			clear_all_selections()
			current_ui.get_child(0).get_child(1).update_selection(true)
			current_schematic_container.show_plant(1)
	elif event.is_action_pressed("plant_3"):
		plant_selected = true
		if current_ui:
			clear_all_selections()
			current_ui.get_child(0).get_child(2).update_selection(true)
			current_schematic_container.show_plant(2)
	elif event.is_action_pressed("plant_4"):
		plant_selected = true
		if current_ui:
			clear_all_selections()
			current_ui.get_child(0).get_child(3).update_selection(true)
			current_schematic_container.show_plant(3)
	elif event.is_action_pressed("plant_5"):
		plant_selected = true
		if current_ui:
			clear_all_selections()
			current_ui.get_child(0).get_child(4).update_selection(true)
			current_schematic_container.show_plant(4)
	return plant_selected

func set_current_mode(new_mode: int):
	if current_mode == new_mode:
		return
	current_mode = new_mode

func set_new_ui(packed_scene: PackedScene):
	var new_ui = packed_scene.instance()
	ui_container.add_child(new_ui)
	current_ui = new_ui

func clear_all_selections():
	current_schematic_container.hide_plant()
	for child in current_ui.get_child(0).get_children():
		child.update_selection(false)
