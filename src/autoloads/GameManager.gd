extends Node

var gold: int = 150
var food: float = 100.0
var max_food: float = 200.0
var mana: float = 50.0
var max_mana: float = 100.0
var core_health: float = 100.0
var max_core_health: float = 100.0
var wave: int = 1
var materials: Dictionary = {
	"mucus": 0, "poison": 0, "fang": 0, "wood": 0, "snow": 0, "stone": 0
}

var is_placing_unit: bool = false
var base_food_rate: float = 5.0
var base_mana_rate: float = 1.0

func _process(delta):
	if food < max_food:
		food = min(max_food, food + base_food_rate * delta)
		SignalBus.resource_changed.emit("food", food)
	if mana < max_mana:
		mana = min(max_mana, mana + base_mana_rate * delta)
		SignalBus.resource_changed.emit("mana", mana)

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
		SignalBus.resource_changed.emit("material", materials)

func spend_material(type: String, amount: int) -> bool:
	if materials.has(type) and materials[type] >= amount:
		materials[type] -= amount
		SignalBus.resource_changed.emit("material", materials)
		return true
	return false

func take_damage(amount: float):
	core_health -= amount
	SignalBus.core_health_changed.emit(core_health)
	if core_health <= 0:
		# Game Over logic
		pass

func _ready():
	SignalBus.enemy_reached_core.connect(take_damage)
