extends Node

@onready var wave_manager = $WaveManager

func _ready():
	print("Test started")
	wave_manager.spawn_request.connect(_on_spawn_request)
	wave_manager.wave_ended.connect(_on_wave_ended)

	wave_manager.start_wave()

func _on_spawn_request(enemy_type, position):
	print("Spawn Enemy at ", position)

func _on_wave_ended():
	print("Wave ended")
	# Allow some time for output to flush if needed, then quit
	get_tree().quit()
