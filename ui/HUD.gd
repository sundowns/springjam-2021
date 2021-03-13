extends Control

onready var selection_ui: Control = $SelectionUI
onready var plant_selection: Control = $BuildUI/PlantSelection
onready var plant_only: Control = $SelectionUI/PlantOnly
onready var schematic_only: Control = $SelectionUI/SchematicOnly
onready var io_selection: Control = $SelectionUI/PlantOnly/InputOutputSelection

onready var victory_popup: PopupPanel = $VictoryPopup

export(NodePath) var camera_path
onready var camera: Camera = get_node(camera_path)

var current_selectable: Selectable
var is_selection_mode := false
var selection_type = ""

func _ready():
# warning-ignore:return_value_discarded
	WinResource.connect("game_complete", self, "_show_victory_popup")

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
			set_io_window_position(parent)

func set_io_window_position(plant: Plant):
	var screen_position := camera.unproject_position(plant.global_transform.origin)
	io_selection.set_position(screen_position - io_selection.rect_size/2 + Vector2(0, 18))

func _process(_delta):
	if is_selection_mode and current_selectable != null:
		var parent = current_selectable.parent
		if parent and parent is Plant:
			set_io_window_position(parent)

func _show_victory_popup():
	victory_popup.popup_centered(Vector2(500, 240))
