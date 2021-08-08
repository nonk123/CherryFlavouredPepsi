extends Projectile


onready var linger_timer := $LingerTimer


func _physics_process(_delta: float) -> void:
	if linear_velocity.length_squared() < 0.01 and linger_timer.time_left != 0:
		linger_timer.start()
