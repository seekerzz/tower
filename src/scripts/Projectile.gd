extends Area2D

var velocity = Vector2.ZERO
var speed = 0.0
var damage = 0.0
var target = null
var max_life = 2.0
var proj_type = "dot"
var splash = 0.0

@onready var label = $Label

func setup(data):
	global_position = data.position
	target = data.target
	speed = data.speed
	damage = data.damage
	proj_type = data.type
	splash = data.splash

	if target and is_instance_valid(target):
		velocity = global_position.direction_to(target.global_position) * speed

	# Visuals
	match proj_type:
		"fire": label.text = "🔥"
		"rocket": label.text = "🚀"
		"orb": label.text = "🔮"
		_: label.text = "•"

func _process(delta):
	max_life -= delta
	if max_life <= 0:
		queue_free()
		return

	if target and is_instance_valid(target) and proj_type != "pellet": # Homing?
		velocity = global_position.direction_to(target.global_position) * speed

	position += velocity * delta

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		hit_enemy(body)
		queue_free()

func hit_enemy(enemy):
	if splash > 0:
		var enemies = get_tree().get_nodes_in_group("enemies")
		for e in enemies:
			if e.global_position.distance_to(global_position) <= splash:
				e.take_damage(damage)
	else:
		enemy.take_damage(damage)
