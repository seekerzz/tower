extends Node2D

var type_key: String
var stats: Dictionary
var level: int = 1
var cooldown: float = 0.0
var tile_pos: Vector2i

# Stats modifiers
var range_mod: float = 1.0
var atk_speed_mod: float = 1.0
var damage_mod: float = 1.0
var active_buffs: Array = []
var traits: Array = []

@onready var label: Label = $Label
@onready var bg: ColorRect = $ColorRect

func setup(key: String, _tile_pos: Vector2i):
	tile_pos = _tile_pos
	type_key = key
	var GameData = load("res://src/scripts/GameData.gd")
	stats = GameData.UNIT_TYPES[key].duplicate()

	label.text = stats.icon
	# Size is handled by the GridManager usually, but visual size:
	var size_px = stats.size * 60 # TILE_SIZE
	bg.size = Vector2(size_px)
	bg.position = -bg.size / 2

	# Initial cooldown
	cooldown = 0.0

func _process(delta):
	if cooldown > 0:
		cooldown -= delta

	if not stats.get("damage", 0) > 0:
		handle_passive_production(delta)
		return

	if cooldown <= 0:
		attempt_attack()

var production_cooldown = 1.0
func handle_passive_production(delta):
	if stats.has("produce"):
		production_cooldown -= delta
		if production_cooldown <= 0:
			production_cooldown = 1.0
			GameManager.add_resource(stats["produce"], stats["produceAmt"])
			# Visual popup could go here

func attempt_attack():
	# Cost Check
	var f_cost = stats.get("foodCost", 0)
	var m_cost = stats.get("manaCost", 0)

	if f_cost > 0 and GameManager.food < f_cost:
		modulate = Color(0.5, 0.5, 0.5) # Visual indication of starvation
		return
	if m_cost > 0 and GameManager.mana < m_cost:
		modulate = Color(0.5, 0.5, 1.0) # Low mana
		return

	modulate = Color.WHITE

	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return

	var target = find_target(enemies)
	if target:
		# Deduct resources
		if f_cost > 0: GameManager.consume_resource("food", f_cost)
		if m_cost > 0: GameManager.consume_resource("mana", m_cost)

		# Set cooldown
		cooldown = stats["atkSpeed"] * atk_speed_mod

		perform_attack(target)

func cast_skill():
	var skill_name = stats.get("skill", "")
	if skill_name == "": return

	print("Casting skill: ", skill_name)

	if skill_name == "stun":
		# Stun all enemies
		var enemies = get_tree().get_nodes_in_group("enemies")
		for e in enemies:
			e.stun_time = 3.0

	elif skill_name == "rage":
		# Increase atk speed for duration
		atk_speed_mod = 0.4 # Faster (lower cooldown)
		await get_tree().create_timer(5.0).timeout
		atk_speed_mod = 1.0

func find_target(enemies):
	var eff_range = stats["range"] * range_mod
	var best_target = null
	var min_dist = INF

	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist <= eff_range and dist < min_dist:
			min_dist = dist
			best_target = enemy

	return best_target

func perform_attack(target):
	var dmg = stats["damage"] * damage_mod * (1.5 if level > 1 else 1.0) # Simple level scaling

	if stats["attackType"] == "melee":
		# AoE Melee?
		var splash = stats.get("splash", 0)
		if splash > 0:
			var enemies = get_tree().get_nodes_in_group("enemies")
			for enemy in enemies:
				if enemy.global_position.distance_to(target.global_position) <= splash:
					enemy.take_damage(dmg)
		else:
			target.take_damage(dmg)

		# Visual Lunge
		var tween = create_tween()
		tween.tween_property(self, "position", position + (target.global_position - global_position).normalized() * 10, 0.1)
		tween.tween_property(self, "position", position, 0.1)

	elif stats["attackType"] == "ranged":
		spawn_projectile(target, dmg)

func spawn_projectile(target, dmg):
	var proj_type = stats.get("proj", "dot")
	var speed = 400
	if proj_type == "rocket": speed = 300

	var data = {
		"position": global_position,
		"target": target, # Homing if Node2D
		"speed": speed,
		"damage": dmg,
		"type": proj_type,
		"splash": stats.get("splash", 0)
	}

	# Decouple instantiation using SignalBus
	SignalBus.projectile_fired.emit(data)
