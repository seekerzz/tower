extends Panel

signal card_clicked(unit_data)

var unit_data: Dictionary
var is_locked: bool = false

@onready var icon_label = $VBoxContainer/Icon
@onready var name_label = $VBoxContainer/Name
@onready var cost_label = $VBoxContainer/Cost
# We might need a lock button reference if we add one, for now implicitly handled or ignored.

func setup_from_data(data: Dictionary, locked: bool = false):
	unit_data = data
	is_locked = locked

	if icon_label: icon_label.text = data.get("icon", "?")
	if name_label: name_label.text = data.get("name", "Unknown")
	if cost_label: cost_label.text = "💰 " + str(data.get("cost", 0))

	if is_locked:
		modulate = Color(0.8, 0.8, 0.5) # Dim/Yellowish for locked? Or border?
	else:
		modulate = Color.WHITE

func _gui_input(event):
	# Click handling is done in parent via signal connection to gui_input usually,
	# or we emit signal here.
	# The GameUI script connects to gui_input manually in the loop.
	# But we can also emit signal for cleaner decoupling.
	pass
