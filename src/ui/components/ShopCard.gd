extends Panel

signal card_clicked

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Card Clicked")
		card_clicked.emit()
