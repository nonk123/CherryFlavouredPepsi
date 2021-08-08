extends HarakiriParticles


var radius := 2.0


func _ready():
	mesh.radius = radius
	mesh.height = radius * 2.0
