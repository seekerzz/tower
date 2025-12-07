extends Node2D

@export var grid_manager: GridManager
# Removed test_unit_scene as we now use dynamic data

enum State { IDLE, PLACING, DRAGGING }
var current_state: State = State.IDLE

var current_unit_stats: UnitStats = null
var drag_start_coord: Vector2i
var dragged_unit: Node2D = null

# Visual ghost
var ghost_label: Label

func _ready() -> void:
	SignalBus.unit_purchased.connect(_on_unit_purchased)

	# Create a simple visual for the ghost
	ghost_label = Label.new()
	ghost_label.modulate.a = 0.5
	ghost_label.visible = false
	add_child(ghost_label)

func _on_unit_purchased(unit_stats: UnitStats) -> void:
	current_unit_stats = unit_stats
	current_state = State.PLACING
	ghost_label.text = unit_stats.icon
	ghost_label.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	print("Entered PLACING state with ", unit_stats.unit_name)

func _unhandled_input(event: InputEvent) -> void:
	# Update ghost position
	if current_state == State.PLACING or current_state == State.DRAGGING:
		ghost_label.global_position = get_global_mouse_position() - Vector2(20, 10) # Offset to center roughly

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_handle_click()
			else:
				_handle_release()

func _handle_click() -> void:
	var mouse_pos = get_global_mouse_position()
	var grid_coord = grid_manager.world_to_grid(mouse_pos)

	match current_state:
		State.PLACING:
			if grid_manager.try_place_unit(grid_coord, current_unit_stats):
				# Success, return to IDLE
				_reset_to_idle()
			else:
				# Placement failed (occupied or invalid), stay in PLACING or cancel?
				# Usually we stay in PLACING until user cancels or places successfully.
				# If user clicks outside grid, maybe cancel?
				# For now, let's just stay in PLACING.
				print("Cannot place here.")

		State.IDLE:
			var unit = grid_manager.get_unit_at(grid_coord)
			if unit:
				current_state = State.DRAGGING
				dragged_unit = unit
				drag_start_coord = grid_coord
				current_unit_stats = unit.stats

				# Visual feedback
				ghost_label.text = unit.stats.icon
				ghost_label.visible = true
				Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

				# Ideally we hide the unit on grid while dragging, or make it transparent
				unit.modulate.a = 0.5

func _handle_release() -> void:
	if current_state == State.DRAGGING:
		var mouse_pos = get_global_mouse_position()
		var target_coord = grid_manager.world_to_grid(mouse_pos)

		# Reset visual
		if dragged_unit:
			dragged_unit.modulate.a = 1.0

		if target_coord == drag_start_coord:
			# Released on same tile, just cancel drag
			_reset_to_idle()
			return

		if not grid_manager.is_valid_grid_pos(target_coord):
			# Invalid target, return to start
			_reset_to_idle()
			return

		var target_unit = grid_manager.get_unit_at(target_coord)

		if target_unit == null:
			# Move to empty spot
			grid_manager.move_unit(drag_start_coord, target_coord)

		elif target_unit.stats.unit_name == dragged_unit.stats.unit_name:
			# Merge
			grid_manager.remove_unit_at(drag_start_coord) # Remove dragged unit from grid record
			target_unit.merge(dragged_unit) # Merge logic destroys the node

		else:
			# Different unit -> Devour (Placeholder)
			print("Devour not implemented yet")
			# Return to original spot
			pass

		_reset_to_idle()

func _reset_to_idle() -> void:
	current_state = State.IDLE
	current_unit_stats = null
	dragged_unit = null
	ghost_label.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event: InputEvent) -> void:
	# Cancel placement with Right Click or Escape
	if current_state == State.PLACING:
		if event.is_action_pressed("ui_cancel") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT):
			# Refund if needed? The task says "Store click deducts money".
			# "Placement failure refunds or just moves position".
			# If we cancel, we should probably refund.
			GameManager.add_gold(current_unit_stats.cost)
			print("Placement cancelled, refunded ", current_unit_stats.cost)
			_reset_to_idle()
