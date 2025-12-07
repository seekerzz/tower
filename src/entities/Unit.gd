extends CharacterBody2D

@export var stats: UnitStats
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

func update_stats() -> void:
	if not stats:
		return
	if label:
		# Display level if > 1
		if level > 1:
			label.text = stats.icon + str(level)
		else:
			label.text = stats.icon

	if range_shape and range_shape.shape is CircleShape2D:
		range_shape.shape.radius = stats.range_radius * stats_multiplier

func merge(other_unit: Node) -> void:
	level += 1
	stats_multiplier += 0.5
	update_stats()
	print("MERGE SUCCESS! New Level: ", level)

	# Destroy the other unit
	other_unit.queue_free()

func _physics_process(delta: float) -> void:
	if attack_cooldown > 0:
		attack_cooldown -= delta

	if target and is_instance_valid(target):
		# Verify target is still in range
		if not _is_target_in_range(target):
			target = null
			find_target()
		else:
			if attack_cooldown <= 0:
				attack(target)
	else:
		find_target()

func _is_target_in_range(target_node: Node2D) -> bool:
	var overlapping = range_area.get_overlapping_bodies()
	return target_node in overlapping

func find_target():
	var bodies = range_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			target = body
			break

func attack(enemy: Node2D):
	# Calculate actual stats based on multiplier
	var final_attack_speed = stats.attack_speed * stats_multiplier
	attack_cooldown = 1.0 / final_attack_speed

	SignalBus.request_projectile_spawn.emit(stats.projectile_type, global_position, enemy)
