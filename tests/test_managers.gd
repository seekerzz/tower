extends Node

func _ready():
	print("Starting tests...")

	# Verify initial state
	assert(GameManager.gold == 150, "Initial gold should be 150")
	print("Initial gold verified: ", GameManager.gold)

	# Verify resource growth
	var initial_food = GameManager.food
	var initial_mana = GameManager.mana

	print("Initial food: ", initial_food)
	print("Initial mana: ", initial_mana)

	# Connect to signals to verify they are emitted
	SignalBus.resource_changed.connect(_on_resource_changed)
	SignalBus.unit_purchased.connect(_on_unit_purchased)

	# Simulate time passing for resource growth
	print("Simulating 1 second wait...")
	await get_tree().create_timer(1.1).timeout

	print("Food after 1s: ", GameManager.food)
	print("Mana after 1s: ", GameManager.mana)

	# Cornucopia gives +5 base food rate, plus default 5 = 10/s.
	# Actually ref.html says: baseFoodRate: 5. cornucopia bonus: { foodRate: 5 }. Total 10.
	# But wait, GameManager.gd logic: base_food_rate = 5.0. _ready adds 5.0. So 10.0.
	# So after 1s, food should be ~110.

	assert(GameManager.food > initial_food, "Food should have increased")
	assert(GameManager.mana > initial_mana, "Mana should have increased")

	# Test SignalBus
	print("Testing SignalBus...")
	SignalBus.unit_purchased.emit(null)

	print("All tests passed!")
	get_tree().quit()

func _on_resource_changed(resource, value):
	# print("Resource changed: ", resource, " -> ", value)
	pass

func _on_unit_purchased(unit):
	print("Signal received: unit_purchased")
