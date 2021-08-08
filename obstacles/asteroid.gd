extends StaticBody


export var radius := 16.0
export var density := 3.2

var mass = 0.75 * PI * pow(radius, 3.0) * density


func _ready() -> void:
	var mesh = SphereMesh.new()
	
	mesh.rings = 16
	mesh.radial_segments = 16
	
	mesh.height = radius * 2.0
	mesh.radius = radius
	
	$MeshInstance.mesh = mesh
	$CollisionShape.shape = mesh.create_convex_shape()
