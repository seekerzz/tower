extends Node2D

func _ready() -> void:
	# Load UnitStats script explicitly
	var UnitStatsScript = load("res://src/resources/UnitStats.gd")
	var stats = UnitStatsScript.new()
	stats.unit_name = "Test Mouse"
	stats.icon = "🐭"
	stats.damage = 10
	stats.range_val = 200.0
	stats.atk_speed = 0.5

	# Setup Unit
	var unit_scene = load("res://src/entities/Unit.tscn")
	var unit = unit_scene.instantiate()
	unit.stats = stats
	unit.position = Vector2(300, 300)
	add_child(unit)

	# Setup Enemy
	var enemy = Node2D.new()
	enemy.name = "Enemy"
	enemy.add_to_group("enemy")
	enemy.position = Vector2(400, 300) # Inside range (200)

	# Add script to enemy to handle take_damage
	var enemy_script = GDScript.new()
	enemy_script.source_code = """
extends Node2D
var hp = 100
func take_damage(amount):
	hp -= amount
	print("Enemy took damage: ", amount, ". HP: ", hp)
	if hp <= 0:
		queue_free()
"""
	if enemy_script.reload() != OK:
		printerr("Failed to reload enemy script")

	enemy.set_script(enemy_script)
	add_child(enemy)

	print("Test scene ready. Unit at ", unit.position, ", Enemy at ", enemy.position)

	# Run for a few seconds then quit
	await get_tree().create_timer(2.0).timeout
	print("Test finished")
	get_tree().quit()
