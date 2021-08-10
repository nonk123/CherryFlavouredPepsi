extends MeshInstance


var health_percentage := 1.0


func _ready() -> void:
	set_surface_material(0, mesh.material.duplicate())


func _process(_delta: float) -> void:
	get_surface_material(0).albedo_color = Global.get_colour_from_health(health_percentage)
