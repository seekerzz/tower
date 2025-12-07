extends CharacterBody2D

@export var stats: Resource
@export var current_level: int = 1
@export var food_cost: int = 0

var cooldown_timer: float = 0.0
var target: Node2D = null

@onready var label: Label = $Label
@onready var range_area: Area2D = $RangeArea
@onready var range_shape: CollisionShape2D = $RangeArea/CollisionShape2D

func _ready() -> void:
	if stats:
		label.text = stats.icon
		food_cost = stats.food_cost

		# Update range shape radius
		if range_shape.shape is CircleShape2D:
			range_shape.shape.radius = stats.range_val

		# Queue redraw to show range
		queue_redraw()

func _process(delta: float) -> void:
	if cooldown_timer > 0:
		cooldown_timer -= delta

	if cooldown_timer <= 0:
		find_target()
		if target:
			attack()

func find_target() -> void:
	var enemies = get_tree().get_nodes_in_group("enemy")
	var nearest_dist = INF
	var nearest_enemy = null

	var my_pos = global_position
	var range_sq = 0.0
	if stats:
		range_sq = stats.range_val * stats.range_val
	else:
		range_sq = 100.0 * 100.0 # Default fallback

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue

		var dist_sq = my_pos.distance_squared_to(enemy.global_position)
		if dist_sq <= range_sq:
			if dist_sq < nearest_dist:
				nearest_dist = dist_sq
				nearest_enemy = enemy

	target = nearest_enemy

func attack() -> void:
	if not target or not is_instance_valid(target):
		return

	print("Attack!")
	if target.has_method("take_damage"):
		var dmg = 1
		if stats:
			dmg = stats.damage
		target.take_damage(dmg)

	if stats:
		cooldown_timer = stats.atk_speed
	else:
		cooldown_timer = 1.0

func _draw() -> void:
	if stats:
		draw_circle(Vector2.ZERO, stats.range_val, Color(1, 1, 1, 0.1))
		draw_arc(Vector2.ZERO, stats.range_val, 0, TAU, 32, Color(1, 1, 1, 0.3), 1.0)
