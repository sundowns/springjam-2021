extends PlantInfo

onready var sunshine_slot: ItemSlot = $VBoxContainer/Control/ItemSlots/Slot
onready var water_slot: ItemSlot = $VBoxContainer/Control/ItemSlots/Slot2
onready var seed_slot: ItemSlot =$VBoxContainer/Control/ItemSlots/Slot3

func update_slot_info(data):
	water_slot.set_current_load(data[0].item_count)
	seed_slot.set_current_load(data[1].item_count)
	sunshine_slot.set_current_load(data[2].item_count)
