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


func spawn_particles(particles: CPUParticles) -> void:
	space.particles.add_child(particles)
