extends Control

onready var dismiss_timer: Timer = $DismissTimer
onready var text_box: RichTextLabel = $RichTextLabel
onready var dismiss_button: Button = $DismissButton
const auto_dismiss := 60.0

onready var prompt_io_timer: Timer = $PromptIOTimer
var has_shown_io_prompt := false

onready var io_reminder_timer: Timer = $IOReminderTimer
var has_shown_io_reminder := false

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
	show_text("Welcome to Plantorio!\n\nSelect a schematic by pressing a number key (1-5) and place it by clicking an unoccupied space in the garden.\n\nTry placing a Watervine (2) to start water production!")

func _on_first_watervine_built():
	show_text("Your first Watervine is producing!\n\nBuilding plants spends resources from the Builder Inventory (see: top-left).\n\nTry building a pipe (1) next to our Watervine.")

func _on_first_pipe_built():
	show_text("You can move resources into your inventory or other plants using pipes! \n\nTry extending a path from a Watervine to the Builder Inventory. \n\nPipes can be extended and destroyed (X) only from their ends.", 40)
	prompt_io_timer.start(60)

func _on_first_seedmother_built():
	show_text("You've built a Seedmother, pipe in water to produce seeds!\n\nYou'll need some in your inventory to build new plants and some to produce sunshine.")
	io_reminder_timer.start(65)

func _on_first_sunflower_built():
	show_text("You've built a Sunflower, pipe in water and seeds to produce sunshine!\n\nSunshine must be refined in a Sunshine Incubator to progress the season.")

func _on_first_incubator_built():
	show_text("You've built a Sunshine Incubator, pipe in water and sunshine to refine it!\n\nRefine 50 sunshine to usher in Spring and complete your garden!")

func _on_IOReminderTimer_timeout():
	if has_shown_io_reminder:
		return
	else:
		if visible:
			io_reminder_timer.start(20)
		else:
			show_text("Don't forget to check if all your plants are inputting and outputting resources! \n\nClick on a plant to see what it currently holds, as well as from where it inputs and outputs resources.", 60)
			has_shown_io_reminder = true

func _on_PromptIOTimer_timeout():
	if has_shown_io_prompt:
		return
	else:
		if visible:
			prompt_io_timer.start(20)
		else:
			show_text("To push and pull produce from pipes, you must configure the inputs and outputs of a plant.\n\nSelect a plant and click on the overlay UI to set I/O behaviour for a direction.", 60)
			has_shown_io_prompt = true

