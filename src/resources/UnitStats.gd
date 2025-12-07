extends Resource
class_name UnitStats

@export var unit_name: String = ""
@export var icon: String = "❓"
@export var cost: int = 10
@export var damage: int = 0
@export var range_val: float = 100.0 # 'range' is a reserved keyword in some contexts, safe to use range_val
@export var atk_speed: float = 1.0
@export var food_cost: int = 0
@export var mana_cost: int = 0
@export var attack_type: String = "melee" # "melee", "ranged", "none"
@export var proj_type: String = "dot"
@export var buff_provider_type: String = "none" # "speed", "range", "none"
@export_multiline var desc: String = ""
