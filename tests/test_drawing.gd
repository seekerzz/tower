extends Node2D

func _ready():
	print("Test started. Simulating drawing...")
	await get_tree().create_timer(1.0).timeout

	# Simulate drawing a wall
	var start_pos = Vector2(300, 300)
	var end_pos = Vector2(700, 300)

	print("Simulating press at ", start_pos)
	_simulate_mouse_press(start_pos)
	await get_tree().create_timer(0.1).timeout

	# Simulate some steps
	for i in range(10):
		var t = float(i) / 9.0
		var pos = start_pos.lerp(end_pos, t)
		_simulate_mouse_move(pos)
		await get_tree().create_timer(0.01).timeout

	print("Simulating release at ", end_pos)
	_simulate_mouse_release(end_pos)

	print("Drawing simulation finished.")

	await get_tree().create_timer(0.5).timeout
	_verify_barricade()

	await get_tree().create_timer(2.0).timeout
	print("Test complete.")
	get_tree().quit()

func _simulate_mouse_press(pos: Vector2):
	get_viewport().warp_mouse(pos)
	var ev = InputEventMouseButton.new()
	ev.position = pos
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true
	Input.parse_input_event(ev)

func _simulate_mouse_move(pos: Vector2):
	get_viewport().warp_mouse(pos)
	var ev = InputEventMouseMotion.new()
	ev.position = pos
	Input.parse_input_event(ev)

func _simulate_mouse_release(pos: Vector2):
	get_viewport().warp_mouse(pos)
	var ev = InputEventMouseButton.new()
	ev.position = pos
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = false
	Input.parse_input_event(ev)

func _verify_barricade():
	var barricades = []
	for child in get_children():
		# Barricade scene instance name might be 'Barricade' or 'Barricade2', etc.
		if child.has_method("setup"):
			barricades.append(child)

	if barricades.size() > 0:
		print("SUCCESS: Barricade created.")
		var b = barricades[0]
		# Check if CollisionPolygon2D has points
		var poly_node = b.get_node("CollisionPolygon2D")
		if poly_node and poly_node.polygon.size() > 0:
			print("SUCCESS: Collision polygon generated with points: ", poly_node.polygon.size())
		else:
			print("FAILURE: Collision polygon is empty or missing.")
	else:
		print("FAILURE: No barricade found.")
