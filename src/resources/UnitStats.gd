extends Resource
class_name UnitStats

@export var unit_name: String
@export var icon: String
@export var cost: int
@export var damage: int
@export var range_val: int
@export var attack_speed: float
@export var food_cost: float
@export var mana_cost: float
@export var attack_type: String = "ranged" # melee, ranged, none
@export var projectile_type: String = "dot"
