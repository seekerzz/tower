extends CharacterBody2D

var stats: Dictionary = {}
var current_hp: float
var max_hp: float
var speed: float
var damage: float
var attack_type: String
var attack_range: float
var atk_speed: float
var cooldown: float = 0.0
var target: Node2D = null

# Status effects
var effects: Dictionary = {} # { "burn": time, "poison": time, "slow": time }
var stun_time: float = 0.0

@onready var label: Label = $Label
@onready var color_rect: ColorRect = $ColorRect
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _ready():
	add_to_group("enemies")
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	# NavigationAgent setup would go here if we used navmesh, but we'll use simple movement towards 0,0 first

func setup(type_key: String, wave_mod: float = 1.0):
	var GameData = load("res://src/scripts/GameData.gd")
	if not GameData.ENEMY_VARIANTS.has(type_key):
		type_key = "slime"

	var data = GameData.ENEMY_VARIANTS[type_key]
	stats = data

	var base_hp = 10 + (wave_mod * 8)
	max_hp = base_hp * data.hpMod
	current_hp = max_hp
	speed = (40 + (wave_mod * 2)) * data.spdMod
	damage = data.dmg # Should scale?
	attack_range = data.range
	atk_speed = data.atkSpeed
	attack_type = data.attackType

	# Visuals
	label.text = data.icon
	# Adjust font size based on radius
	label.add_theme_font_size_override("font_size", int(data.radius * 2))
	color_rect.color = data.color
	color_rect.size = Vector2(data.radius * 2, data.radius * 2)
	color_rect.position = -color_rect.size / 2

	# Collision shape (assuming CircleShape2D)
	$CollisionShape2D.shape.radius = data.radius

func _physics_process(delta):
	process_effects(delta)

	if stun_time > 0:
		stun_time -= delta
		return

	if current_hp <= 0:
		die()
		return

	# Movement Logic
	var target_pos = Vector2.ZERO
	var direction = global_position.direction_to(target_pos)
	var dist = global_position.distance_to(target_pos)

	if dist < 30: # Reached core
		attack_core(delta)
	else:
		velocity = direction * speed
		# Apply slow
		if effects.has("slow") and effects["slow"] > 0:
			velocity *= 0.5

		move_and_slide()
		check_collisions(delta)

func check_collisions(delta):
	# Simple collision attack logic
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("barricades"):
			attack_barricade(collider, delta)
			# Only attack one thing at a time
			break

func attack_barricade(barricade, delta):
	if cooldown > 0:
		cooldown -= delta
	else:
		cooldown = atk_speed
		if barricade.has_method("take_damage"):
			barricade.take_damage(damage)
			# Reflect damage?
			if barricade.props.get("type") == "reflect":
				take_damage(barricade.props.get("strength", 0), "reflect")
			# Slow effect from hitting?
			if barricade.props.get("type") == "slow":
				effects["slow"] = 2.0

func process_effects(delta):
	var to_remove = []
	for effect in effects:
		effects[effect] -= delta
		if effect == "burn":
			take_damage(2 * delta, "burn")
		elif effect == "poison":
			take_damage((max_hp * 0.05) * delta, "poison")

		if effects[effect] <= 0:
			to_remove.append(effect)

	for effect in to_remove:
		effects.erase(effect)

func take_damage(amount: float, source: String = "unknown"):
	current_hp -= amount
	# Visual feedback could go here
	if current_hp <= 0:
		die()

func attack_core(delta):
	if cooldown > 0:
		cooldown -= delta
	else:
		cooldown = atk_speed
		GameManager.damage_core(damage)
		# Push back slightly
		var direction = global_position.direction_to(Vector2.ZERO)
		global_position -= direction * 5

func die():
	SignalBus.enemy_died.emit(self)
	# Drop loot logic
	if stats.has("drop") and randf() < stats.get("dropRate", 0.3):
		GameManager.add_resource(stats["drop"], 1)

	GameManager.add_resource("gold", 1)
	GameManager.add_resource("food", 2)
	queue_free()
