extends Area

onready var collision_shape: CollisionShape = $CollisionShape

func enable():
	collision_shape.disabled = false

func disable():
	collision_shape.disabled = true
