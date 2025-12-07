extends Area2D

var target: Node2D
var speed: float = 400.0
var damage: float = 0.0

func _physics_process(delta):
	if is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		position += direction * speed * delta
	else:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.take_damage(damage)
		queue_free()
