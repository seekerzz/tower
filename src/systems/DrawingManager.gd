extends Node2D

const BarricadeScene = preload("res://src/objects/Barricade.tscn")

var is_drawing: bool = false
var start_point: Vector2
var preview_line: Line2D

func _ready():
	preview_line = Line2D.new()
	preview_line.width = 10.0
	preview_line.default_color = Color(1, 1, 1, 0.5)
	add_child(preview_line)
	preview_line.visible = false

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_drawing(event.position)
			else:
				_finish_drawing(event.position)
	elif event is InputEventMouseMotion:
		if is_drawing:
			_update_drawing(event.position)

func _get_global_pos(screen_pos: Vector2) -> Vector2:
	return get_canvas_transform().affine_inverse() * screen_pos

func _start_drawing(screen_pos: Vector2):
	is_drawing = true
	start_point = _get_global_pos(screen_pos)
	preview_line.points = PackedVector2Array([start_point, start_point])
	preview_line.visible = true

func _update_drawing(screen_pos: Vector2):
	var current_point = _get_global_pos(screen_pos)
	preview_line.points = PackedVector2Array([start_point, current_point])

func _finish_drawing(screen_pos: Vector2):
	if not is_drawing:
		return

	is_drawing = false
	preview_line.visible = false

	var end_point = _get_global_pos(screen_pos)

	# Minimum length check
	if start_point.distance_to(end_point) < 5.0:
		return

	var barricade = BarricadeScene.instantiate()
	get_parent().add_child(barricade)

	# Set global position to zero so points (which are global coordinates in this approach) align correctly
	barricade.global_position = Vector2.ZERO
	barricade.setup(PackedVector2Array([start_point, end_point]))
