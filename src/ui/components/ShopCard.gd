extends Panel

var unit_data: UnitStats

@onready var icon_label = $VBoxContainer/IconLabel
@onready var name_label = $VBoxContainer/NameLabel
@onready var cost_label = $VBoxContainer/CostLabel

func _ready():
	if unit_data:
		icon_label.text = unit_data.icon
		name_label.text = unit_data.unit_name
		cost_label.text = str(unit_data.cost) + " G"

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if GameManager.spend_gold(unit_data.cost):
			SignalBus.card_clicked.emit(unit_data)
			queue_free() # Remove card after buy? Or just disable?
