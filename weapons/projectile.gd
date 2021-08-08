class_name Projectile
extends RigidBody


var damage: float
var team := 0


func _ready() -> void:
	contacts_reported = 1
	contact_monitor = true
	var _ignored = connect("body_entered", self, "_on_collision")


func _on_collision(body: PhysicsBody) -> void:
	if body.has_method("deal_damage"):
		body.deal_damage(damage)
		queue_free()
