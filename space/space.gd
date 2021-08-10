class_name Space
extends Spatial


const G_CONSTANT = 0.015

export var extents := 300.0

export var asteroid_count := 40
export var asteroid_private_space := 15.0
export var min_asteroid_size := 2.0
export var max_asteroid_size := 15.0

export var enemies_count := 3

onready var asteroids := $Asteroids
onready var spaceships := $Spaceships
onready var projectiles := $Projectiles
onready var particles := $Particles


func _ready() -> void:
	randomize()
	place_asteroids()
	place_enemies()
	
	ensure_player_exists()
	
	Global.space = self


func _physics_process(_delta: float) -> void:
	ensure_player_exists()
	
	for body in Global.get_bodies_affected_by_gravity():
		var total_gravity := Vector3.ZERO
		
		for asteroid in $Asteroids.get_children():
			var numerator = G_CONSTANT * body.mass * asteroid.mass
			var direction = asteroid.translation - body.translation
			total_gravity += direction.normalized() * numerator / direction.length_squared()
		
		body.add_central_force(total_gravity)


func ensure_player_exists() -> void:
	var player: Spaceship = spaceships.get_node_or_null("Player")
	
	if not player:
		player = preload("res://spaceship/spaceship.tscn").instance()
		player.name = "Player"
		player.set_script(preload("res://spaceship/player.gd"))
		spaceships.add_child(player)


func is_occupied(point: Vector3, radius: float) -> bool:
	var solids := asteroids.get_children()
	solids.append_array(spaceships.get_children())
	
	for solid in solids:
		if point.distance_to(solid.translation) < radius + solid.radius:
			return true
	
	return false


func get_random_point(radius: float) -> Vector3:
	while true:
		var point := Vector3(randf() - 0.5, randf() - 0.5, randf() - 0.5) * 2.0 * extents
		
		if not is_occupied(point, radius):
			return point
	
	return Vector3.ZERO


func place_asteroids() -> void:
	for _i in range(asteroid_count):
		var asteroid := preload("res://obstacles/asteroid.tscn").instance()
		asteroid.radius = min_asteroid_size + randf() * (max_asteroid_size - min_asteroid_size)
		asteroid.translation = get_random_point(asteroid_private_space + asteroid.radius)
		asteroids.add_child(asteroid)


func place_enemies() -> void:
	for _i in range(enemies_count):
		var enemy := preload("res://spaceship/spaceship.tscn").instance()
		enemy.translation = get_random_point(enemy.radius)
		enemy.set_script(preload("res://spaceship/enemy.gd"))
		spaceships.add_child(enemy)
