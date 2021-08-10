extends Node


var space: Space

var spaceships: Array setget, get_spaceships
var asteroids: Array setget, get_asteroids


func get_spaceships() -> Array:
	return space.spaceships.get_children() if space else []


func get_asteroids() -> Array:
	return space.asteroids.get_children() if space else []


func get_projectiles() -> Array:
	return space.projectiles.get_children() if space else []


func get_bodies_affected_by_gravity() -> Array:
	var nodes := get_spaceships()
	nodes.append_array(get_projectiles())
	return nodes


func spawn_explosion(radius: float, duration: float, position: Vector3):
	var particles = preload("res://spaceship/explosion.tscn").instance()
	particles.radius = radius
	particles.lifetime = duration
	particles.translation = position
	space.particles.add_child(particles)


func get_colour_from_health(health_percentage: float) -> Color:
	var full_health := Color(0.1, 1.0, 0.0)
	var some_health := Color(0.8, 0.8, 0.0)
	var low_health := Color(1.0, 0.1, 0.0)
	
	if health_percentage >= 0.5:
		var weight := 2.0 * (health_percentage - 0.5)
		return some_health.linear_interpolate(full_health, weight)
	else:
		var weight := 2.0 * health_percentage
		return low_health.linear_interpolate(some_health, weight)
