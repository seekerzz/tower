extends CharacterBody2D

@export var stats: UnitStats

@onready var label = $Label
@onready var range_area = $RangeArea
@onready var range_collision = $RangeArea/CollisionShape2D

var cooldown: float = 0.0

func _ready():
	update_stats()

func set_stats(new_stats):
	stats = new_stats
	update_stats()

func update_stats():
	if stats and is_inside_tree():
		label.text = stats.icon
		var circle = CircleShape2D.new()
		circle.radius = stats.range_val
		range_collision.shape = circle

func _process(delta):
	if cooldown > 0:
		cooldown -= delta
		return

	if stats and stats.damage > 0:
		var target = find_target()
		if target:
			attack(target)

func find_target():
	var bodies = range_area.get_overlapping_bodies()
	var closest = null
	var min_dist = INF
	for body in bodies:
		if body.is_in_group("enemies"):
			var dist = global_position.distance_to(body.global_position)
			if dist < min_dist:
				min_dist = dist
				closest = body
	return closest

func attack(target):
	if GameManager.food < stats.food_cost:
		return # Not enough food
	if GameManager.mana < stats.mana_cost:
		return # Not enough mana

	GameManager.food -= stats.food_cost
	GameManager.mana -= stats.mana_cost
	cooldown = stats.attack_speed

	if stats.attack_type == "melee":
		# Simple melee hit
		target.take_damage(stats.damage)
	elif stats.attack_type == "ranged":
		# Spawn projectile
		var proj = load("res://src/objects/Projectile.tscn").instantiate()
		proj.position = global_position
		proj.target = target
		proj.damage = stats.damage
		proj.speed = 400
		get_tree().root.add_child(proj)
