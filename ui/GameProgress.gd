extends Control


onready var progress_bar: ProgressBar = $ProgressBar

func _ready():
	progress_bar.max_value = WinResource.AMOUNT_TO_WIN
	progress_bar.value = WinResource.current_amount
	WinResource.connect("win_resource_amount_update", self, "_on_resource_update")

func _on_resource_update(new_value: int):
	progress_bar.value = WinResource.current_amount
