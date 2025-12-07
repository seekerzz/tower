extends CanvasLayer

@onready var shop_container = $BottomPanel/HBoxContainer/ShopContainer
@onready var bench_container = $BottomPanel/HBoxContainer/BenchContainer

func _ready():
	pass

func add_shop_card(card_scene):
	var card = card_scene.instantiate()
	shop_container.add_child(card)
