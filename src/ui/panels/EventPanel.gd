extends CanvasLayer

signal option_selected(option_id)

@onready var container = $ColorRect/HBoxContainer

func setup(options: Array):
	# options: Array of Dictionary { "id": String, "text": String }
	var buttons = container.get_children()
	for i in range(buttons.size()):
		if i < options.size():
			var btn = buttons[i]
			btn.text = options[i].text
			btn.visible = true

			# Disconnect if already connected to avoid duplicates
			if btn.pressed.is_connected(_on_button_pressed):
				btn.pressed.disconnect(_on_button_pressed)

			# Connect with bound argument
			# Note: In Godot 4, we bind arguments like this
			btn.pressed.connect(_on_button_pressed.bind(options[i].id))
		else:
			buttons[i].visible = false

func _on_button_pressed(option_id):
	option_selected.emit(option_id)
