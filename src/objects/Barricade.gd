extends StaticBody2D

@onready var line_2d: Line2D = $Line2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D

var type_key: String = "wood"
var hp: float = 100.0
var max_hp: float = 100.0
var props: Dictionary = {}

func setup(points: PackedVector2Array):
	if points.size() < 2:
		return

	if GameData.BARRICADE_TYPES.has(type_key):
		props = GameData.BARRICADE_TYPES[type_key]
		hp = props["hp"]
		max_hp = props["hp"]
		line_2d.width = props["width"]
		line_2d.default_color = Color(props["color"])

	line_2d.points = points

	# Generate collision polygon from line
	var width = line_2d.width
	var polygons = Geometry2D.offset_polyline(points, width / 2.0)

	if polygons.size() > 0:
		collision_polygon_2d.polygon = polygons[0]

	# Add to group so enemies can detect it
	add_to_group("barricades")

func take_damage(amount: float):
	hp -= amount
	# TODO: Visual damage indication (color change or particles)
	if hp <= 0:
		die()

func die():
	queue_free()
