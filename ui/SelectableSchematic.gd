extends Control

onready var selection_overlay: ColorRect = $SchematicIcon/SelectionOverlay

var is_selected = false

func update_selection(_is_selected: bool):
	is_selected = _is_selected
	selection_overlay.visible = _is_selected
