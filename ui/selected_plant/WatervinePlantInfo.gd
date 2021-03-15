extends PlantInfo

onready var water_slot: ItemSlot = $VBoxContainer/Control/ItemSlots/Slot

func update_slot_info(data):
	water_slot.set_current_load(data[0].item_count)
