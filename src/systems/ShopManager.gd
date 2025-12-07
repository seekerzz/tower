extends Node

var unit_resources = []

func _ready():
	load_units()

func load_units():
	var dir = DirAccess.open("res://src/resources/units/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var res = load("res://src/resources/units/" + file_name)
				if res is UnitStats:
					unit_resources.append(res)
			file_name = dir.get_next()

func get_random_units(count: int) -> Array:
	var result = []
	if unit_resources.size() == 0:
		return result

	for i in range(count):
		result.append(unit_resources.pick_random())
	return result
