extends Spatial

func _ready():
# warning-ignore:return_value_discarded
	$World.connect("mode_changed", $CanvasLayer/HUD, "_on_mode_change", [], CONNECT_DEFERRED)
# warning-ignore:return_value_discarded
	$World.connect("selection_changed", $CanvasLayer/HUD, "_on_selection_changed", [], CONNECT_DEFERRED)
