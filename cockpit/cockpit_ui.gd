extends Control


export var max_enemy_markers := 5

var player: Spaceship

var local_up: Vector3

onready var root := $CockpitContainer/Viewport/Root


func _process(_delta: float) -> void:
	root.rotation = player.rotation
	local_up = root.transform.basis.xform(Vector3.UP)
	
	update_crosshair()
	draw_velocity_vector()
	draw_enemy_markers()
	draw_prediction_line()


func update_crosshair() -> void:
	var crosshair := root.get_node("Crosshair")
	var health_percentage := player.health / player.max_health
	crosshair.mesh.material.albedo_color = Global.get_colour_from_health(health_percentage)


func draw_velocity_vector() -> void:
	var new_length := player.linear_velocity.length()
	new_length = clamp(new_length, 6.5, 30.0)
	
	var distance := player.linear_velocity.normalized() * new_length
	var velocity_vector := root.get_node("VelocityVector")
	velocity_vector.look_at_from_position(distance, Vector3.ZERO, local_up)


func draw_enemy_markers() -> void:
	var enemies := player.get_enemies_by_distance()
	var enemy_markers := root.get_node("EnemyMarkers")
	
	var new_count := min(len(enemies), max_enemy_markers)
	var old_count := enemy_markers.get_child_count()
	
	if new_count > old_count:
		for _i in range(new_count - old_count):
			enemy_markers.add_child(preload("res://cockpit/enemy_marker.tscn").instance())
	elif new_count < old_count:
		for _i in range(old_count - new_count):
			var child := enemy_markers.get_child(0)
			enemy_markers.remove_child(child)
			child.queue_free()
	
	for idx in range(new_count):
		var enemy_marker := enemy_markers.get_child(idx)
		var enemy: Spaceship = enemies[idx]
		
		var position = enemy.translation - player.translation
		var distance = position.length()
		
		enemy_marker.look_at_from_position(position.normalized(), Vector3.ZERO, local_up)
		enemy_marker.scale.x = max(0.02, enemy.radius / distance)
		enemy_marker.scale.y = enemy_marker.scale.x
		
		var percentage := enemy.health / enemy.max_health
		var marker_ring := enemy_marker.get_node("MarkerRing")
		marker_ring.health_percentage = percentage


# Doesn't work at all.
func draw_prediction_line() -> void:
	var enemies := player.get_enemies_by_distance()
	var predictions := root.get_node("Predictions")
	
	var new_count := min(len(enemies), max_enemy_markers)
	var old_count := predictions.get_child_count()
	
	if new_count > old_count:
		for _i in range(new_count - old_count):
			predictions.add_child(preload("res://cockpit/prediction_line.tscn").instance())
	elif new_count < old_count:
		for _i in range(old_count - new_count):
			var child := predictions.get_child(0)
			predictions.remove_child(child)
			child.queue_free()
	
	for idx in range(new_count):
		var enemy: Spaceship = enemies[idx]
		
		var enemy_velocity := enemy.linear_velocity \
				+ enemy.transform.basis.xform(enemy.velocity_control) * enemy.acceleration
		
		var line_origin := enemy.translation - player.translation + enemy_velocity * 0.5
		
		var line: Spatial = predictions.get_child(idx).get_node("PredictionLine")
		line.look_at_from_position(line_origin, Vector3.ZERO, local_up)
		line.scale.x = enemy_velocity.length()
