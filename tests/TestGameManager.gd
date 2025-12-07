extends Node

func _ready():
	print("Testing GameManager...")

	GameManager.gold = 100
	GameManager.add_gold(50)
	if GameManager.gold == 150:
		print("Gold added correctly.")
	else:
		print("Gold add failed: ", GameManager.gold)

	var success = GameManager.spend_gold(200)
	if not success and GameManager.gold == 150:
		print("Gold spend blocked correctly.")
	else:
		print("Gold spend logic failed.")

	success = GameManager.spend_gold(50)
	if success and GameManager.gold == 100:
		print("Gold spend success correctly.")
	else:
		print("Gold spend success failed.")

	print("GameManager tests passed.")
	get_tree().quit()
