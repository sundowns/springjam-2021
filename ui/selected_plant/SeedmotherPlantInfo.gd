extends PlantInfo

onready var seed_slot: ItemSlot = $VBoxContainer/Control/ItemSlots/Slot
onready var water_slot: ItemSlot = $VBoxContainer/Control/ItemSlots/Slot2

func update_slot_info(data):
	water_slot.set_current_load(data[0].item_count)
	seed_slot.set_current_load(data[1].item_count)
