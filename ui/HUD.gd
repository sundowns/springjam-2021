extends Control

func _on_mode_change(is_build_mode: bool):
	$BuildUI.visible = is_build_mode
	$SelectionUI.visible = not is_build_mode

func _on_selection_changed(selected_node: Plant):
	print('update selection UI')
