extends StaticBody2D

var hp: float
var max_hp: float
var type: String
var props: Dictionary

signal barricade_destroyed(barricade)

func setup(p1: Vector2, p2: Vector2, material_type: String):
	if not GameData.BARRICADE_TYPES.has(material_type):
		material_type = "wood"

	props = GameData.BARRICADE_TYPES[material_type]
	type = material_type
	max_hp = props.hp
	hp = max_hp

	add_to_group("barricades")

func take_damage(amount: float):
	hp -= amount
	# Visual feedback?
	if hp <= 0:
		die()

func die():
	barricade_destroyed.emit(self)
	queue_free()
