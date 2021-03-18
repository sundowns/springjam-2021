extends Control

onready var dismiss_timer: Timer = $DismissTimer
onready var text_box: RichTextLabel = $RichTextLabel
onready var dismiss_button: Button = $DismissButton
const auto_dismiss := 45.0

onready var prompt_io_timer: Timer = $PromptIOTimer

var has_shown_io_prompt := false

func _ready():
	visible = false
# warning-ignore:return_value_discarded
	PlantCosts.connect("inventory_plant_ready", self, "_on_inventory_ready")
# warning-ignore:return_value_discarded
	Global.connect("first_pipe_built", self, "_on_first_pipe_built")
# warning-ignore:return_value_discarded
	Global.connect("first_watervine_built", self, "_on_first_watervine_built")
# warning-ignore:return_value_discarded
	Global.connect("first_seedmother_built", self, "_on_first_seedmother_built")
# warning-ignore:return_value_discarded
	Global.connect("first_sunflower_built", self, "_on_first_sunflower_built")
# warning-ignore:return_value_discarded
	Global.connect("first_incubator_built", self, "_on_first_incubator_built")

func show_text(text: String, override_time: float = 0.0):
	text_box.text = text
	visible = true
	dismiss_timer.stop()
	if override_time == 0.0:
		dismiss_timer.start(auto_dismiss)
	else:
		dismiss_timer.start(override_time)

func dismiss():
	visible = false
	dismiss_timer.stop()

func _on_DismissTimer_timeout():
	dismiss()

func _on_DismissButton_pressed():
	dismiss()

func _process(_delta):
	dismiss_button.text = "Dismiss (%d)" % dismiss_timer.time_left

func _on_inventory_ready():
	show_text("Place new plant schematics by selecting one with the number keys (1-5) and clicking on unoccupied space in the garden.\n\nTry placing a Watervine (2) to start water production!")

func _on_first_watervine_built():
	show_text("Your first Watervine is producing!\n\nBuilding plants spends resources from the Builder Inventory (shown top-left), let's automate adding water to the inventory.\n\nTry building a pipe (1) next to our Watervine.")

func _on_first_pipe_built():
	show_text("Pipes can be extended and destroyed (X) only from their ends.\n\nTry extending a path from a Watervine to the Build Inventory.", 35)
	prompt_io_timer.start(40)

func _on_first_seedmother_built():
	show_text("You've built a Seedmother, pipe in water to produce seeds!\n\nYou'll need some in the Builder Inventory and some for sunshine production.")

func _on_first_sunflower_built():
	show_text("You've built a Sunflower, pipe in water and seeds to produce sunshine!\n\nSunshine must be refined in a Sunshine Incubator to progress the season.")

func _on_first_incubator_built():
	show_text("You've built a Sunshine Incubator, pipe in water and sunshine to refine it!\n\nRefine 50 sunshine to usher in Spring and complete your garden!")

func _on_PromptIOTimer_timeout():
	if has_shown_io_prompt:
		return
	else:
		if visible:
			prompt_io_timer.start(10)
		else:
			show_text("To push and pull produce from pipes, you must configure the inputs and outputs of a plant.\n\nSelect a plant and click on the overlay UI to set I/O behaviour for a direction.", 60)
			has_shown_io_prompt = true
