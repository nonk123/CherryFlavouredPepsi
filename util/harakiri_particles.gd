class_name HarakiriParticles
extends CPUParticles



func _ready() -> void:
	emitting = true


func _process(_delta: float) -> void:
	if not emitting:
		queue_free()
