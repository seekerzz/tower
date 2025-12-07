extends Node

var gold: int = 150
var food: float = 100.0
var max_food: float = 200.0
var mana: float = 50.0
var max_mana: float = 100.0
var wave: int = 1
var core_health: float = 100.0
var max_core_health: float = 100.0

var materials: Dictionary = {
	"mucus": 0, "poison": 0, "fang": 0, "wood": 50, "snow": 0, "stone": 20
}

# Core types: cornucopia, thunder, alchemy, war
var core_type: String = "cornucopia"

func _ready():
	reset_game()

func reset_game():
	gold = 150
	food = 100.0
	max_food = 200.0
	mana = 50.0
	max_mana = 100.0
	wave = 1
	core_health = 100.0
	materials = {
		"mucus": 0, "poison": 0, "fang": 0, "wood": 50, "snow": 0, "stone": 20
	}

func add_resource(type: String, amount: float):
	match type:
		"gold":
			gold += int(amount)
			SignalBus.resource_changed.emit("gold", gold)
		"food":
			food = min(food + amount, max_food)
			SignalBus.resource_changed.emit("food", food)
		"mana":
			mana = min(mana + amount, max_mana)
			SignalBus.resource_changed.emit("mana", mana)
		_:
			if type in materials:
				materials[type] += int(amount)
				SignalBus.resource_changed.emit(type, materials[type])

func consume_resource(type: String, amount: float) -> bool:
	match type:
		"gold":
			if gold >= amount:
				gold -= int(amount)
				SignalBus.resource_changed.emit("gold", gold)
				return true
		"food":
			if food >= amount:
				food -= amount
				SignalBus.resource_changed.emit("food", food)
				return true
		"mana":
			if mana >= amount:
				mana -= amount
				SignalBus.resource_changed.emit("mana", mana)
				return true
		_:
			if type in materials and materials[type] >= amount:
				materials[type] -= int(amount)
				SignalBus.resource_changed.emit(type, materials[type])
				return true
	return false

func damage_core(amount: float):
	core_health -= amount
	SignalBus.core_damaged.emit(core_health)
	if core_health <= 0:
		SignalBus.game_over.emit(wave)
