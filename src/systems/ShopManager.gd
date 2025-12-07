extends Node

# Since we don't have a dedicated resource loader for units yet, we'll manually list them or load from dir.
# For simplicity, I'll load from a hardcoded list of paths, or try to list the directory.
# Directory listing works in editor but might be tricky in exported builds if not handled carefully.
# For now, listing directory is fine.

signal shop_updated(cards_data)

var available_units: Array[UnitStats] = []
var shop_size: int = 4

func _ready():
	_load_units()

func _load_units():
	var dir = DirAccess.open("res://src/resources/units/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var unit = load("res://src/resources/units/" + file_name)
				if unit is UnitStats:
					available_units.append(unit)
			file_name = dir.get_next()
	else:
		print("Failed to open units directory.")

func refresh_shop() -> Array[UnitStats]:
	var selection: Array[UnitStats] = []
	if available_units.is_empty():
		return selection

	for i in range(shop_size):
		selection.append(available_units.pick_random())

	return selection
