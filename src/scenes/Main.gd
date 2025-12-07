extends Node2D

@onready var grid_manager = $GridManager
@onready var wave_manager = $WaveManager
@onready var drawing_manager = $DrawingManager
@onready var ui = $CanvasLayer/GameUI
@onready var entity_layer = $EntityLayer

var placement_mode = false
var placement_unit_key = ""
var ghost_preview: Node2D

func _ready():
	# Initial Core Setup
	# Place core at 0,0
	# We can't really "place" a unit there in GridManager without hacking it as GridManager prevents placing on 0,0 if we set it so.
	# But let's assume GridManager handles non-core tiles.
	# Or better, spawn the core visual manually here.
	SignalBus.projectile_fired.connect(_on_projectile_fired)
	spawn_core_visual()

func _on_projectile_fired(data):
	var proj_scene = load("res://src/scenes/Projectile.tscn")
	var proj = proj_scene.instantiate()
	entity_layer.add_child(proj)
	proj.setup(data)

func spawn_core_visual():
	var core = Label.new()
	core.text = "⚛️" # Core icon
	core.add_theme_font_size_override("font_size", 40)
	core.position = Vector2(-20, -30)
	$GridOrigin.add_child(core)

func start_placement(key):
	placement_mode = true
	placement_unit_key = key
	drawing_manager.active = false

	if ghost_preview: ghost_preview.queue_free()
	ghost_preview = load("res://src/scenes/Unit.tscn").instantiate()
	ghost_preview.modulate = Color(1, 1, 1, 0.5)
	add_child(ghost_preview)

func start_drawing(material_key):
	placement_mode = false
	if ghost_preview:
		ghost_preview.queue_free()
		ghost_preview = null

	drawing_manager.active = true
	drawing_manager.current_material = material_key

func _unhandled_input(event):
	if placement_mode:
		if event is InputEventMouseMotion:
			var mouse_pos = get_global_mouse_position()
			var grid_pos = grid_manager.world_to_grid(mouse_pos)
			var snap_pos = grid_manager.grid_to_world(grid_pos)
			if ghost_preview:
				ghost_preview.position = snap_pos

		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_pos = get_global_mouse_position()
			var grid_pos = grid_manager.world_to_grid(mouse_pos)

			if grid_manager.try_place_unit(placement_unit_key, grid_pos):
				GameManager.consume_resource("gold", GameData.UNIT_TYPES[placement_unit_key].cost)
				placement_mode = false
				if ghost_preview:
					ghost_preview.queue_free()
					ghost_preview = null
			else:
				# Show error feedback
				pass

		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			placement_mode = false
			if ghost_preview:
				ghost_preview.queue_free()
				ghost_preview = null
