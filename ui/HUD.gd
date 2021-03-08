extends Control

onready var selection_ui: Control = $SelectionUI
onready var plant_selection: Control = $BuildUI/PlantSelection

func _on_mode_change(hud_mode: int):
	selection_ui.visible = hud_mode == HudModes.SELECTION
	plant_selection.current_mode = hud_mode

func _on_selection_changed(_selected_node: Selectable):
	pass
