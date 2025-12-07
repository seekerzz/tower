extends Panel

signal card_clicked(unit_data)

var unit_data: UnitStats

@onready var icon_label = $VBoxContainer/Icon
@onready var name_label = $VBoxContainer/Name
@onready var cost_label = $VBoxContainer/Cost

func setup(data: UnitStats):
	unit_data = data
	icon_label.text = data.icon
	name_label.text = data.unit_name
	cost_label.text = "💰 " + str(data.cost)

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Card Clicked: ", unit_data.unit_name)
		card_clicked.emit(unit_data)
