extends Node2D

@export var grid_manager: Node2D

var placement_mode: bool = false
var selected_unit_data: UnitStats

func _ready():
	SignalBus.card_clicked.connect(_on_card_clicked)

func _on_card_clicked(unit_data):
	selected_unit_data = unit_data
	placement_mode = true
	GameManager.is_placing_unit = true

func _unhandled_input(event):
	if placement_mode and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var grid_pos = grid_manager.world_to_grid(get_global_mouse_position())
		if grid_manager.try_place_unit(load("res://src/entities/Unit.tscn"), grid_pos):
			# Setup stats
			var unit = grid_manager.grid_data[grid_pos]["unit"]
			unit.set_stats(selected_unit_data)
			placement_mode = false
			selected_unit_data = null
			GameManager.is_placing_unit = false
		else:
			# Placement failed (occupied, etc)
			pass

	if event.is_action_pressed("ui_cancel"):
		placement_mode = false
		selected_unit_data = null
		GameManager.is_placing_unit = false
