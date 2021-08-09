extends Spaceship


const MOUSE_SENSITIVITY := 0.15
const MAX_ENEMY_MARKERS := 5

var mouse_speed := Vector2.ZERO

var selected_enemy: Spaceship
var local_up: Vector3

var cockpit_root: Spatial


func _ready() -> void:
	$Camera.make_current()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	add_child(preload("res://spaceship/cockpit_ui.tscn").instance())
	cockpit_root = $Cockpit/CockpitContainer/Viewport/Root


func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var motion_event := event as InputEventMouseMotion
		mouse_speed = motion_event.relative


func _process(_delta: float) -> void:
	cockpit_root.rotation = rotation
	local_up = transform.basis.xform(Vector3.UP)
	
	draw_velocity_vector()
	draw_enemy_markers()
	draw_prediction_line()


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


func draw_velocity_vector() -> void:
	var distance := linear_velocity.normalized()
	var velocity_vector := cockpit_root.get_node("VelocityVector")
	
	if linear_velocity.length() > 0.5:
		velocity_vector.look_at_from_position(distance, Vector3.ZERO, local_up)
	else:
		velocity_vector.translation = Vector3.ZERO


func draw_enemy_markers() -> void:
	var enemies := get_enemies_by_distance()
	var enemy_markers := cockpit_root.get_node("EnemyMarkers")
	
	var new_count := min(len(enemies), MAX_ENEMY_MARKERS)
	var old_count := enemy_markers.get_child_count()
	
	if new_count > old_count:
		for _i in range(new_count - old_count):
			var enemy_marker := preload("res://spaceship/enemy_marker.tscn").instance()
			enemy_markers.add_child(enemy_marker)
	elif new_count < old_count:
		for _i in range(old_count - new_count):
			var child := enemy_markers.get_child(0)
			enemy_markers.remove_child(child)
			child.queue_free()
	
	for idx in range(new_count):
		var enemy_marker := enemy_markers.get_child(idx)
		var enemy: Spaceship = enemies[idx]
		
		var position = enemy.translation - translation
		var distance = position.length()
		
		enemy_marker.look_at_from_position(position.normalized(), Vector3.ZERO, local_up)
		enemy_marker.scale.x = max(0.02, enemy.radius / distance)
		enemy_marker.scale.y = enemy_marker.scale.x
		
		var percentage := enemy.health / enemy.max_health
		var marker_ring := enemy_marker.get_node("MarkerRing")
		marker_ring.health_percentage = percentage


func draw_prediction_line() -> void:
	var enemies := get_enemies_by_distance()
	selected_enemy = enemies[0] if enemies else null
	
	if not selected_enemy:
		return
	
	var enemy_velocity := selected_enemy.linear_velocity + selected_enemy.velocity_control * selected_enemy.acceleration
	var line_origin := selected_enemy.translation + enemy_velocity * 0.5 - translation
	
	var line: Spatial = cockpit_root.get_node("PredictionLine")
	line.look_at_from_position(line_origin, Vector3.ZERO, local_up)
	line.scale.x = enemy_velocity.length()
