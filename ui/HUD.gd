extends Control

onready var selection_ui: Control = $SelectionUI
onready var plant_selection: Control = $BuildUI/PlantSelection
onready var plant_only: Control = $SelectionUI/PlantOnly
onready var schematic_only: Control = $SelectionUI/SchematicOnly
onready var io_selection: Control = $SelectionUI/PlantOnly/InputOutputSelection

var current_selectable: Selectable
var is_selection_mode := false
var selection_type = ""

func _on_mode_change(hud_mode: int):
	is_selection_mode = hud_mode == HudModes.SELECTION
	update_selection_ui()
	plant_selection.current_mode = hud_mode

func _on_selection_changed(in_selected_node: Selectable):
	current_selectable = in_selected_node
	update_selection_ui()

func update_selection_ui():
	selection_ui.visible = is_selection_mode and current_selectable != null
	if current_selectable:
		var parent = current_selectable.parent
		schematic_only.visible = parent is Schematic
		plant_only.visible = parent is Plant
		if parent is Plant:
			io_selection.update_selected_plant(parent)
