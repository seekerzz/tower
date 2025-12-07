extends CharacterBody2D

@export var max_hp: float = 10.0
@export var speed: float = 50.0
@export var damage: float = 5.0
@export var icon: String = "👾"

var hp: float

@onready var label = $Label

func _ready():
	hp = max_hp
	label.text = icon
	add_to_group("enemies")

func _physics_process(delta):
	# Move towards center (0,0)
	var direction = (Vector2.ZERO - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

	if global_position.distance_to(Vector2.ZERO) < 30:
		SignalBus.enemy_reached_core.emit(damage)
		queue_free()

func take_damage(amount: float):
	hp -= amount
	# Visual flash could go here
	if hp <= 0:
		die()

func die():
	SignalBus.enemy_died.emit(self)
	GameManager.add_gold(1)

	# Chance to drop material
	if randf() < 0.3:
		var mats = ["wood", "stone", "mucus", "poison", "fang", "snow"]
		var drop = mats.pick_random()
		GameManager.add_material(drop, 1)

	queue_free()
