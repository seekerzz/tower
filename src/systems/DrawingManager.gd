extends Node2D

var active: bool = false
var start_pos: Vector2
var current_pos: Vector2
var current_material: String = ""

@onready var line_preview: Line2D = Line2D.new()

func _ready():
	line_preview.width = 5
	line_preview.default_color = Color.WHITE
	add_child(line_preview)

func _unhandled_input(event):
	if not active or current_material == "":
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_drawing(get_global_mouse_position())
			else:
				finish_drawing()
	elif event is InputEventMouseMotion and active and start_pos != Vector2.ZERO:
		current_pos = get_global_mouse_position()
		update_preview()

func start_drawing(pos):
	start_pos = pos
	current_pos = pos
	update_preview()

func update_preview():
	line_preview.points = [start_pos, current_pos]

func finish_drawing():
	if start_pos.distance_to(current_pos) < 20:
		start_pos = Vector2.ZERO
		line_preview.points = []
		return

	# Calculate Cost
	var dist = start_pos.distance_to(current_pos)
	var cost = ceil(dist / 10.0)

	if GameManager.consume_resource(current_material, cost):
		create_barricade(start_pos, current_pos, current_material)

	start_pos = Vector2.ZERO
	line_preview.points = []

func create_barricade(p1, p2, material):
	var barricade = StaticBody2D.new()
	barricade.set_script(load("res://src/scripts/Barricade.gd"))

	var GameData = load("res://src/scripts/GameData.gd")
	var mat_data = GameData.BARRICADE_TYPES[material]

	# Visual
	var line = Line2D.new()
	line.points = [p1, p2]
	line.width = mat_data.width
	line.default_color = mat_data.color
	barricade.add_child(line)

	# Collision
	var collision = CollisionShape2D.new()
	var segment = SegmentShape2D.new()
	segment.a = p1
	segment.b = p2
	collision.shape = segment
	barricade.add_child(collision)

	# Setup script data
	barricade.setup(p1, p2, material)

	get_parent().get_node("EntityLayer").add_child(barricade)
