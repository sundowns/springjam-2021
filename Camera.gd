extends Camera

export(float) var friction: float = 1.0
export(float) var speed: float = 5.0

var velocity: Vector3 = Vector3.ZERO

func _physics_process(delta):
	var direction = Vector3.ZERO
	if Input.is_action_pressed("ui_left"):
		direction += Vector3(-1,0,0)
	if Input.is_action_pressed("ui_right"):
		direction += Vector3(1,0,0)
	if Input.is_action_pressed("ui_up"):
		direction += Vector3(0,0,-1)
	if Input.is_action_pressed("ui_down"):
		direction += Vector3(0,0,1)
	velocity = direction * speed

func _process(delta):
	global_transform.origin += velocity * delta
	velocity = velocity.move_toward(Vector3.ZERO, delta * friction)
