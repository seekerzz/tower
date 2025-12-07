extends Node

signal wave_started
signal wave_ended
signal spawn_request(enemy_type, position)

var current_wave: int = 1
var is_wave_active: bool = false
var enemies_to_spawn: int = 0
var total_wave_enemies: int = 0
var enemies_alive: int = 0
var batches_left: int = 0
var enemies_per_batch: int = 0
var current_batch_spawned: int = 0
var current_batch_type: String = ""
var current_batch_angle: float = 0.0

@onready var spawn_timer: Timer = $SpawnTimer
@onready var batch_delay_timer: Timer = Timer.new()
@onready var warning_timer: Timer = Timer.new()

func _ready():
	add_child(batch_delay_timer)
	batch_delay_timer.one_shot = true
	batch_delay_timer.timeout.connect(_start_next_batch)

	add_child(warning_timer)
	warning_timer.one_shot = true
	warning_timer.timeout.connect(_spawn_batch_units)

	if spawn_timer:
		spawn_timer.timeout.connect(_on_spawn_unit)
		spawn_timer.wait_time = 0.1 # Fast spawn within batch

	SignalBus.game_over.connect(_on_game_over)

func start_wave():
	if is_wave_active: return

	is_wave_active = true
	current_wave = GameManager.wave

	# Calculate enemies count
	var base_count = 20 + floor(current_wave * 6)
	enemies_to_spawn = base_count
	total_wave_enemies = base_count
	enemies_alive = 0

	# Reset resources and cooldowns (ref.html logic)
	GameManager.food = GameManager.max_food
	GameManager.mana = GameManager.max_mana

	SignalBus.wave_started.emit(current_wave)

	# Schedule Batches
	var batch_count = 3 + floor(current_wave / 2.0)
	batches_left = batch_count
	enemies_per_batch = ceil(float(enemies_to_spawn) / float(batch_count))

	_start_next_batch()

func _start_next_batch():
	if not is_wave_active or batches_left <= 0:
		return

	# Determine Type
	var type_key = _get_wave_type(current_wave)
	if type_key == "boss":
		current_batch_type = "boss"
	elif type_key == "normal":
		var variants = ["slime", "wolf", "poison", "shooter"]
		current_batch_type = variants.pick_random()
	else:
		current_batch_type = type_key # Fallback

	if not GameData.ENEMY_VARIANTS.has(current_batch_type):
		current_batch_type = "slime"

	# Pick Angle
	current_batch_angle = randf() * TAU

	# Show Warning
	_show_warning(current_batch_angle, current_batch_type)

	# Wait for warning (1.5s)
	warning_timer.start(1.5)

func _show_warning(angle: float, type_key: String):
	# TODO: Implement visual warning in GameUI or here via signal
	# For now, just print
	# print("Warning: %s coming from %.2f" % [type_key, angle])
	pass

func _spawn_batch_units():
	if not is_wave_active: return

	current_batch_spawned = 0
	spawn_timer.start() # Start pumping out units

func _on_spawn_unit():
	if not is_wave_active or current_batch_spawned >= enemies_per_batch or enemies_to_spawn <= 0:
		spawn_timer.stop()
		batches_left -= 1

		if batches_left > 0:
			var next_delay = max(2.0, 4.0 - (current_wave * 0.1))
			batch_delay_timer.start(next_delay)
		return

	var angle = current_batch_angle + (randf() - 0.5) * 0.8
	var dist = 600.0 # Outside screen roughly
	var spawn_pos = Vector2(cos(angle), sin(angle)) * dist

	spawn_request.emit(current_batch_type, spawn_pos)

	enemies_to_spawn -= 1
	current_batch_spawned += 1
	enemies_alive += 1

func enemy_died():
	enemies_alive -= 1
	_check_wave_end()

func _check_wave_end():
	if enemies_to_spawn <= 0 and enemies_alive <= 0 and is_wave_active:
		_end_wave()

func _end_wave():
	is_wave_active = false
	spawn_timer.stop()
	batch_delay_timer.stop()
	warning_timer.stop()

	GameManager.wave += 1
	GameManager.add_gold(20 + GameManager.wave * 5)

	SignalBus.wave_ended.emit()

func _get_wave_type(n: int) -> String:
	if n % 10 == 0: return "boss"
	# Event logic handled elsewhere? ref.html handles events every 3 waves
	var types = ["slime", "wolf", "poison", "treant", "yeti", "golem"]
	var idx = min(types.size() - 1, floor((n-1)/2.0))
	return types[int(idx) % types.size()]

func _on_game_over(wave):
	is_wave_active = false
	spawn_timer.stop()
	batch_delay_timer.stop()
	warning_timer.stop()
