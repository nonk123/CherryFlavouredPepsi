extends Spaceship


func _init():
	team = 1


func _process(_delta: float) -> void:
	var enemies := get_enemies_by_distance()
	var nearest_enemy := enemies[0] as Spaceship if enemies else null
	
	if nearest_enemy:
		var distance := nearest_enemy.translation - translation
		velocity_control = transform.basis.xform_inv(distance).normalized()
