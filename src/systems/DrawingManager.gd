extends Node2D

var drawing: bool = false
var start_point: Vector2
var current_point: Vector2
var material_type: String = "wood"

func _unhandled_input(event):
	if GameManager.is_placing_unit:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if GameManager.materials[material_type] > 0: # Check cost
					drawing = true
					start_point = get_global_mouse_position()
					current_point = start_point
			else:
				if drawing:
					finish_drawing()
					drawing = false
	elif event is InputEventMouseMotion and drawing:
		current_point = get_global_mouse_position()
		queue_redraw()

func _draw():
	if drawing:
		draw_line(start_point, current_point, Color.BROWN, 5.0)

func finish_drawing():
	# Create StaticBody2D
	var distance = start_point.distance_to(current_point)
	var cost = ceil(distance / 10.0)

	# Basic cost check again
	if GameManager.spend_material(material_type, cost):
		create_barricade(start_point, current_point)
	queue_redraw()

func create_barricade(p1, p2):
	var barricade = StaticBody2D.new()
	var collision = CollisionShape2D.new()
	var segment = SegmentShape2D.new()
	segment.a = p1
	segment.b = p2
	collision.shape = segment
	barricade.add_child(collision)

	var line = Line2D.new()
	line.points = [p1, p2]
	line.width = 5.0
	line.default_color = Color.BROWN
	barricade.add_child(line)

	add_child(barricade)
