extends HarakiriParticles


export var radius := 3.0


func _ready():
	mesh = SphereMesh.new()
	
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 16
	mesh.rings = mesh.radial_segments
	
	mesh.material = preload("res://spaceship/explosion_material.tres")
