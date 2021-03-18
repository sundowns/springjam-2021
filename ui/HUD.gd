extends Control

onready var selection_ui: Control = $SelectionUI
onready var plant_selection: Control = $BuildUI/PlantSelection
onready var plant_only: Control = $SelectionUI/PlantOnly
onready var schematic_only: Control = $SelectionUI/SchematicOnly
onready var io_selection: Control = $SelectionUI/PlantOnly/InputOutputSelection

onready var victory_popup: PopupPanel = $VictoryPopup
onready var plantinfo_container: Control = $SelectionUI/PlantOnly/SelectedPlantInfoContainer
onready var watervine_info: Control = $SelectionUI/PlantOnly/SelectedPlantInfoContainer/Watervine
onready var seedmother_info: Control = $SelectionUI/PlantOnly/SelectedPlantInfoContainer/Seedmother
onready var sunflower_info: Control = $SelectionUI/PlantOnly/SelectedPlantInfoContainer/Sunflower
onready var incubator_info: Control = $SelectionUI/PlantOnly/SelectedPlantInfoContainer/Incubator
onready var pipe_info: Control = $SelectionUI/PlantOnly/SelectedPlantInfoContainer/PipeNode
onready var inventory_info: Control = $SelectionUI/PlantOnly/SelectedPlantInfoContainer/Inventory


export(NodePath) var camera_path
onready var camera: Camera = get_node(camera_path)

var current_selectable: Selectable
var is_selection_mode := false
var is_pipe_mode := false
var selection_type = ""

func _ready():
# warning-ignore:return_value_discarded
	WinResource.connect("game_complete", self, "_show_victory_popup")
	$BuildUI.visible = false
# warning-ignore:return_value_discarded
	PlantCosts.connect("inventory_plant_ready", self, "_on_inventory_plant_ready")

func _on_mode_change(hud_mode: int):
	is_selection_mode = hud_mode == HudModes.SELECTION
	is_pipe_mode = hud_mode == HudModes.BUILD_PIPES
	update_selection_ui()
	plant_selection.current_mode = hud_mode

func _on_selection_changed(in_selected_node: Selectable):
	if current_selectable and current_selectable.parent is Plant:
		if current_selectable.parent.plant_name != "inventory":
			current_selectable.parent.disconnect("slot_data_changed", self, "_on_selected_slot_change")
	
	current_selectable = in_selected_node
	for child in plantinfo_container.get_children():
		child.visible = false
		
	if current_selectable and current_selectable.parent is Plant:
		if current_selectable.parent.plant_name != "inventory":
			current_selectable.parent.connect("slot_data_changed", self, "_on_selected_slot_change")
			_on_selected_slot_change(current_selectable.parent.item_slots)
		match current_selectable.parent.plant_name:
			"watervine":
				watervine_info.visible = true
			"seedmother":
				seedmother_info.visible = true
			"sunflower":
				sunflower_info.visible = true
			"incubator":
				incubator_info.visible = true
			"inventory":
				inventory_info.visible = true
	if current_selectable and current_selectable.parent is PipeNode:
		pipe_info.visible = true
	
	update_selection_ui()

func _on_selected_slot_change(data):
	if current_selectable and current_selectable.parent is Plant:
		match current_selectable.parent.plant_name:
			"watervine":
				watervine_info.update_slot_info(data)
			"seedmother":
				seedmother_info.update_slot_info(data)
			"sunflower":
				sunflower_info.update_slot_info(data)
			"incubator":
				incubator_info.update_slot_info(data)

func update_selection_ui():
	selection_ui.visible = (is_selection_mode or is_pipe_mode) and current_selectable != null
	if current_selectable:
		var parent = current_selectable.parent
		schematic_only.visible = parent is Schematic
		plant_only.visible = parent is Plant or parent is PipeNode
		if parent is Plant:
			io_selection.update_selected_plant(parent)
			set_io_window_position(parent)
			io_selection.visible = true
		else:
			io_selection.visible = false

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

func _on_inventory_plant_ready():
	$BuildUI.visible = true
