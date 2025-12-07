extends Node

class_name InteractionController

@export var grid_manager: GridManager
@export var test_unit_scene: PackedScene

var placement_mode: bool = false

func _ready() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_B:
			placement_mode = !placement_mode
			print("Placement mode: ", placement_mode)

	if placement_mode and event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if grid_manager and test_unit_scene:
				var mouse_pos = grid_manager.get_global_mouse_position()
				var grid_pos = grid_manager.world_to_grid(mouse_pos)
				grid_manager.try_place_unit(test_unit_scene, grid_pos)
