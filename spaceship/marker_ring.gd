extends MeshInstance


var health_percentage := 1.0


func _ready() -> void:
	set_surface_material(0, mesh.material.duplicate())


func _process(_delta: float) -> void:
	var full_health := Color(0.1, 1.0, 0.0)
	var some_health := Color(0.8, 0.8, 0.0)
	var low_health := Color(1.0, 0.1, 0.0)
	
	var final_color: Color
	
	if health_percentage >= 0.5:
		var weight := 2.0 * (health_percentage - 0.5)
		final_color = some_health.linear_interpolate(full_health, weight)
	else:
		var weight := 2.0 * health_percentage
		final_color = low_health.linear_interpolate(some_health, weight)
	
	get_surface_material(0).albedo_color = final_color
