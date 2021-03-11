extends MenuButton

signal selection_changed(name, selection_name)

func _ready():
# warning-ignore:return_value_discarded
	get_popup().connect("id_pressed", self, "_on_item_selected")
	
func _on_item_selected(item_id):
	var item_name = get_popup().get_item_text(item_id)
	set_text(item_name)
	emit_signal("selection_changed", name, item_name)
