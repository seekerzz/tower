extends Node2D

const BarricadeScene = preload("res://src/objects/Barricade.tscn")

var is_drawing: bool = false
var start_point: Vector2
var preview_line: Line2D
var current_material: String = "wood"

func _ready():
	preview_line = Line2D.new()
	preview_line.width = 10.0
	preview_line.default_color = Color(1, 1, 1, 0.5)
	add_child(preview_line)
	preview_line.visible = false

	SignalBus.wave_started.connect(func(_w): set_process_input(false))
	SignalBus.game_over.connect(func(_w): set_process_input(false))

func set_material(material_key: String):
	if GameData.BARRICADE_TYPES.has(material_key):
		current_material = material_key

func _unhandled_input(event):
	if not GameManager.is_wave_active and not is_drawing and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_start_drawing(event.position)
	elif is_drawing:
		if event is InputEventMouseMotion:
			_update_drawing(event.position)
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_finish_drawing(event.position)

func _get_global_pos(screen_pos: Vector2) -> Vector2:
	return get_canvas_transform().affine_inverse() * screen_pos

func _start_drawing(screen_pos: Vector2):
	if not GameData.BARRICADE_TYPES.has(current_material):
		return

	# Check if we have any material to start
	if GameManager.materials.get(current_material, 0) <= 0:
		return

	is_drawing = true
	start_point = _get_global_pos(screen_pos)

	var mat_data = GameData.BARRICADE_TYPES[current_material]
	preview_line.width = mat_data["width"]
	preview_line.default_color = Color(mat_data["color"])

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
	var length = start_point.distance_to(end_point)

	# Minimum length check
	if length < 20.0:
		return

	# Cost Calculation: ref.html -> cost = Math.ceil(dist / 10)
	var cost = ceil(length / 10.0)

	if not GameManager.spend_material(current_material, int(cost)):
		# print("Material不足 (Needs %d %s)" % [cost, current_material])
		# TODO: Show floating text
		return

	var barricade = BarricadeScene.instantiate()
	# We need to add it to the entity layer ideally, but parent is likely DrawingManager or Main
	# Assuming DrawingManager is a child of Main or a System node
	# Best to add to a specific container if possible, but parent works for now
	get_parent().add_child(barricade)

	# Pass data
	barricade.type_key = current_material
	barricade.global_position = Vector2.ZERO
	barricade.setup(PackedVector2Array([start_point, end_point]))
