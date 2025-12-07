extends CharacterBody2D

@export var max_hp: float = 100.0
@export var speed: float = 100.0
@export var damage: float = 10.0

var current_hp: float

func _ready():
	current_hp = max_hp
	# Set a random emoji if not already set or just default
	if $Label.text == "":
		$Label.text = ["🐺", "👹"].pick_random()

func _physics_process(_delta):
	var target_position = Vector2.ZERO
	# Simple movement towards target
	var direction = (target_position - global_position).normalized()
	velocity = direction * speed

	move_and_slide()

func take_damage(amount: float):
	current_hp -= amount
	if current_hp <= 0:
		die()

func die():
	print("Enemy died. Dropping item.")
	queue_free()
