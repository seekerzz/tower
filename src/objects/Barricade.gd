extends StaticBody2D

@onready var line_2d: Line2D = $Line2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D

func setup(points: PackedVector2Array):
	if points.size() < 2:
		return

	line_2d.points = points

	# Generate collision polygon from line
	# We use the line's width to determine the thickness of the wall
	var width = line_2d.width

	# offset_polyline returns an Array of PackedVector2Array.
	# We usually expect one polygon for a simple line.
	var polygons = Geometry2D.offset_polyline(points, width / 2.0)

	if polygons.size() > 0:
		collision_polygon_2d.polygon = polygons[0]
