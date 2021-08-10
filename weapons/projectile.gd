class_name Projectile
extends RigidBody


var damage: float
var team := 0


func _ready() -> void:
	contacts_reported = 1
	contact_monitor = true
	continuous_cd = true
	
	var _ignored := connect("body_entered", self, "_on_collision")


func _on_collision(body: PhysicsBody) -> void:
	if body.has_method("deal_damage"):
		var body_velocity := (body as RigidBody).linear_velocity if body is RigidBody else Vector3.ZERO
		var total_velocity := linear_velocity - body_velocity
		body.deal_damage(damage * total_velocity.length())
	
	var mesh_radius: float = $MeshInstance.mesh.get_aabb().get_longest_axis_size() * 0.5
	Global.spawn_explosion(mesh_radius, 0.6, translation)
	queue_free()
