extends CharacterBody2D

@export var stats: Resource
@export var current_level: int = 1
@export var food_cost: int = 0

var cooldown_timer: float = 0.0
var target: Node2D = null

var applied_buffs: Array = []
var base_stats: Dictionary = {}

@onready var label: Label = $Label
@onready var range_area: Area2D = $Area2D
@onready var range_shape: CollisionShape2D = $Area2D/CollisionShape2D

var target: Node2D = null
var attack_cooldown: float = 0.0

var level: int = 1
var stats_multiplier: float = 1.0

func _ready() -> void:
	if stats:
		update_stats()

		# Cache base stats
		base_stats = {
			"atk_speed": stats.atk_speed,
			"range_val": stats.range_val
		}

		# Update stats based on potential initial buffs (though usually none at spawn)
		update_stats()

func update_stats() -> void:
	if not stats: return

	var current_atk_speed = base_stats["atk_speed"]
	var current_range = base_stats["range_val"]

	for buff in applied_buffs:
		if buff == "speed":
			current_atk_speed *= 0.5 # 50% faster attack speed (lower cooldown)
		elif buff == "range":
			current_range += 50.0

	# Update runtime values
	# We don't modify the Resource 'stats' directly to avoid persisting changes or affecting other units sharing it.
	# But we need to use these values in _process and attack.
	# So we store them in local variables or read them from a local override.
	# For simplicity, let's store them in local variables shadowing the stats access,
	# OR we can just use these variables.
	# Let's add instance variables for these.
	_current_atk_speed = current_atk_speed
	_current_range_val = current_range

	# Update range shape radius
	if range_shape.shape is CircleShape2D:
		range_shape.shape.radius = _current_range_val

	# Queue redraw to show range
	queue_redraw()

var _current_atk_speed: float = 1.0
var _current_range_val: float = 100.0

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
		range_sq = _current_range_val * _current_range_val
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
	if label:
		# Display level if > 1
		if level > 1:
			label.text = stats.icon + str(level)
		else:
			label.text = stats.icon

	# print("Attack!")

	var dmg = 1
	if stats:
		dmg = stats.damage

	if stats and stats.attack_type == "ranged":
		ProjectileFactory.spawn_projectile(get_parent(), global_position, target, stats.proj_type, dmg)
	elif stats and stats.attack_type == "melee":
		if target.has_method("take_damage"):
			target.take_damage(dmg)
	else:
		# Fallback for undefined or legacy
		if target.has_method("take_damage"):
			target.take_damage(dmg)

	if stats:
		cooldown_timer = _current_atk_speed
	else:
		find_target()

func _draw() -> void:
	if stats:
		draw_circle(Vector2.ZERO, _current_range_val, Color(1, 1, 1, 0.1))
		draw_arc(Vector2.ZERO, _current_range_val, 0, TAU, 32, Color(1, 1, 1, 0.3), 1.0)
