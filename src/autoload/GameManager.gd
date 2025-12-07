extends Node

# Resources
var gold: int = 150
var food: float = 100.0
var mana: float = 50.0
var materials: Dictionary = {
	"mucus": 0,
	"poison": 0,
	"fang": 0,
	"wood": 0,
	"snow": 0,
	"stone": 0
}

# Resource limits and rates
var max_food: float = 200.0
var max_mana: float = 100.0
var base_food_rate: float = 5.0
var base_mana_rate: float = 1.0

# Game state
var wave: int = 1
var is_wave_active: bool = false
var core_health: float = 100.0
var max_core_health: float = 100.0
var core_type: String = "cornucopia"

func _ready():
	# Apply initial core type bonus if any
	# Ref logic: if coreType is cornucopia, bonus foodRate: 5
	if core_type == "cornucopia":
		base_food_rate += 5.0
	elif core_type == "alchemy":
		base_mana_rate += 2.0
	elif core_type == "war":
		base_food_rate += -2.5

func _process(delta):
	# Resource growth logic from ref.html
	# if (game.food < game.maxFood) game.food = Math.min(game.maxFood, game.food + fRate * dt);
    # if (game.mana < game.maxMana) game.mana = Math.min(game.maxMana, game.mana + mRate * dt);

	if core_health <= 0:
		return

	if food < max_food:
		var previous_food = food
		food = min(max_food, food + base_food_rate * delta)
		if floor(previous_food) != floor(food):
			SignalBus.resource_changed.emit("food", floor(food))

	if mana < max_mana:
		var previous_mana = mana
		mana = min(max_mana, mana + base_mana_rate * delta)
		if floor(previous_mana) != floor(mana):
			SignalBus.resource_changed.emit("mana", floor(mana))

func add_gold(amount: int):
	gold += amount
	SignalBus.resource_changed.emit("gold", gold)

func spend_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		SignalBus.resource_changed.emit("gold", gold)
		return true
	return false

func add_material(type: String, amount: int):
	if materials.has(type):
		materials[type] += amount
		SignalBus.resource_changed.emit("materials", materials)

func spend_material(type: String, amount: int) -> bool:
	if materials.has(type) and materials[type] >= amount:
		materials[type] -= amount
		SignalBus.resource_changed.emit("materials", materials)
		return true
	return false

func take_damage(amount: float):
	core_health -= amount
	if core_health <= 0:
		core_health = 0
		SignalBus.game_over.emit(wave)
	SignalBus.resource_changed.emit("core_health", core_health)
