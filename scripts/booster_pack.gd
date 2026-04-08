extends Node2D

@export var all_cards: Array[CardData]
@export var target_marker: Marker2D

var is_in_center = false
var start_position: Vector2
var start_scale: Vector2

func _ready():
	start_position = global_position
	start_scale = scale

var rarity_weights = {
	"Common": 60,
	"Rare": 25,
	"Epic": 10,
	"Legendary": 5
}

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not is_in_center:
				move_to_center()
			else:
				open_booster()

func _input(event):
	if event.is_action_pressed("ui_cancel") and is_in_center:
		return_to_start()

func return_to_start():
	is_in_center = false
	
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "global_position", start_position, 0.4)
	tween.parallel().tween_property(self, "scale", start_scale, 0.4)

func move_to_center():
	is_in_center = true
	var screen_center = target_marker.global_position
	
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "global_position", screen_center, 0.4)
	tween.parallel().tween_property(self, "scale", Vector2(1, 1), 0.4)

func open_booster(amount: int = 4) -> Array[CardData]:
	var pulled_cards: Array[CardData] = []
	
	for i in range(amount):
		var card = _get_random_card()
		pulled_cards.append(card)
		print("Выпала карта: ", card.card_name, " [", card.rarity, "]")
		
	return pulled_cards

func _get_random_card() -> CardData:
	var roll = randf_range(0, 100)
	var selected_rarity = "Common"
	
	if roll < rarity_weights["Legendary"]:
		selected_rarity = "Legendary"
	elif roll < rarity_weights["Legendary"] + rarity_weights["Epic"]:
		selected_rarity = "Epic"
	elif roll < rarity_weights["Legendary"] + rarity_weights["Epic"] + rarity_weights["Rare"]:
		selected_rarity = "Rare"
	
	var pool = all_cards.filter(func(c): return c.rarity == selected_rarity)
	
	if pool.is_empty():
		print("Предупреждение: Карт редкости ", selected_rarity, " не найдено в списке!")
		pool = all_cards.filter(func(c): return c.rarity == "Common")
		
	if pool.is_empty():
		push_error("ОШИБКА: Массив all_cards пуст или в нем нет карт с редкостью Common!")
		return null
	
	return pool.pick_random()
