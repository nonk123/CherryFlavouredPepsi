extends Spaceship


const MOUSE_SENSITIVITY := 0.15

var mouse_speed := Vector2.ZERO


func _ready() -> void:
	$Camera.make_current()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	var cockpit_ui = preload("res://cockpit/cockpit_ui.tscn").instance()
	cockpit_ui.player = self
	add_child(cockpit_ui)


func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var motion_event := event as InputEventMouseMotion
		mouse_speed = motion_event.relative


func _physics_process(_delta: float) -> void:
	velocity_control.x = Input.get_action_strength("x+") - Input.get_action_strength("x-")
	velocity_control.y = Input.get_action_strength("y+") - Input.get_action_strength("y-")
	velocity_control.z = Input.get_action_strength("z+") - Input.get_action_strength("z-")
	
	mouse_speed *= -MOUSE_SENSITIVITY
	rotation_control.x = mouse_speed.y
	rotation_control.y = mouse_speed.x
	mouse_speed = Vector2.ZERO
	
	rotation_control.z = Input.get_action_strength("roll+") - Input.get_action_strength("roll-")
	
	halt_control = Input.is_action_pressed("halt")
	
	if Input.is_action_pressed("shoot"):
		shoot()

