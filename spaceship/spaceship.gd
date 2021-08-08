class_name Spaceship
extends RigidBody


class Weapon extends Reference:
	var effective_range: float
	var fire_rate: float
	var damage: float


class ProjectileWeapon extends Weapon:
	var projectile_speed: float
	
	func create_projectile() -> Node:
		push_warning("You forgot to implement create_projectile()!")
		return null


class PlasmaBall extends ProjectileWeapon:
	func _init():
		effective_range = 200.0
		fire_rate = 0.5
		damage = 30.0
		projectile_speed = 50.0
	
	func create_projectile() -> Node:
		return preload("res://weapons/plasma_ball.tscn").instance()


signal dead()


export(Mesh) var mesh = preload("res://spaceship/default_mesh.tres")

export var acceleration := 20.0
export var mobility := 6.0

export var max_speed := 15.0
export var max_torque := 7.0

export var radius := 1.5

export var max_health := 100.0

export var team := 0

var health := max_health
var weapon: Weapon = PlasmaBall.new() setget set_weapon

var velocity_control := Vector3.ZERO
var rotation_control := Vector3.ZERO

var halt_control := false

onready var shooting_timer := $ShootingTimer


func _ready() -> void:
	set_weapon(weapon)
	$MeshInstance.mesh = mesh
	$CollisionShape.shape = mesh.create_convex_shape()


func _integrate_forces(state: PhysicsDirectBodyState) -> void:
	var force := transform.basis.xform(velocity_control) * acceleration
	state.add_central_force(force)
	
	if halt_control:
		var halt := linear_velocity / max_speed * -acceleration
		state.add_central_force(halt)
	
	if state.linear_velocity.length() > max_speed:
		state.linear_velocity = state.linear_velocity.normalized() * max_speed
	
	var torque := transform.basis.xform(rotation_control) * mobility
	state.add_torque(torque)
	
	if state.angular_velocity.length() > max_torque:
		state.angular_velocity = state.angular_velocity.normalized() * max_torque


func shoot() -> void:
	if shooting_timer.time_left != 0:
		return
	
	if weapon is ProjectileWeapon:
		var projectile_weapon := weapon as ProjectileWeapon
		
		var projectile := projectile_weapon.create_projectile() as Projectile
		var projectile_velocity := transform.basis.xform(Vector3.FORWARD) \
				* projectile_weapon.projectile_speed
		
		projectile.translation = transform.xform(Vector3.FORWARD * 2.5)
		projectile.linear_velocity = projectile_velocity + linear_velocity
		projectile.damage = weapon.damage
		projectile.team = team
		
		Global.space.projectiles.add_child(projectile)
		shooting_timer.start()


func get_enemies_by_distance() -> Array:
	var enemies := []
	
	for spaceship in Global.get_spaceships():
		if spaceship.team != team:
			enemies.push_back(spaceship)
	
	enemies.sort_custom(self, "_sort_by_distance")
	return enemies


func _sort_by_distance(a: Spaceship, b: Spaceship) -> bool:
	var distance_a = a.translation.distance_squared_to(translation)
	var distance_b = b.translation.distance_squared_to(translation)
	return distance_a < distance_b


func deal_damage(amount: float) -> void:
	health -= amount
	
	if health <= 0.01:
		emit_signal("dead")
		explode()
		queue_free()


func explode():
	var particles = preload("res://spaceship/explosion.tscn").instance()
	particles.radius = radius
	particles.translation = translation
	Global.spawn_particles(particles)


func set_weapon(new_weapon: Weapon) -> void:
	weapon = new_weapon
	shooting_timer.wait_time = weapon.fire_rate
	shooting_timer.start()
