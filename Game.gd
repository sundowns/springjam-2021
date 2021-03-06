extends Spatial

func _ready():
	$World.connect("mode_changed", $CanvasLayer/HUD, "_on_mode_change", [], CONNECT_DEFERRED)
	$World.connect("selection_changed", $CanvasLayer/HUD, "_on_selection_changed", [], CONNECT_DEFERRED)
