extends Area2D

@export var speed: float = 400.0
@export var damage: int = 10
@export var homing: bool = false

var target: Node2D = null
var velocity: Vector2 = Vector2.ZERO

func _ready():
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta):
	if homing and is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		rotation = velocity.angle()
	else:
		if velocity == Vector2.ZERO:
			velocity = Vector2.RIGHT.rotated(rotation) * speed

	global_position += velocity * delta

func _on_body_entered(body: Node):
	_handle_collision(body)

func _on_area_entered(area: Area2D):
	_handle_collision(area)

func _handle_collision(node: Node):
	if node.is_in_group("Enemy"):
		if node.has_method("take_damage"):
			node.take_damage(damage)
		queue_free()

func set_target(new_target: Node2D):
	target = new_target
