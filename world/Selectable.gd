extends Node
class_name Selectable

export(NodePath) var selectable_entity_path: NodePath = ".."
onready var parent = get_node(selectable_entity_path)

onready var particles: Particles = $SelectedParticles

var is_selected := false setget set_selected

signal selected
signal deselected

func set_selected(new_status: bool):
	particles.emitting = new_status
	is_selected = new_status
	if new_status == true:
		emit_signal("selected")
	else:
		emit_signal("deselected")
