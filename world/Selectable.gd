extends Node
class_name Selectable

export(NodePath) var selectable_entity_path: NodePath = ".."
onready var parent = get_node(selectable_entity_path)

onready var particles: Particles = $SelectedParticles

var is_selected := false setget set_selected

func set_selected(new_status: bool):
	particles.emitting = new_status
	is_selected = new_status
