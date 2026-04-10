extends Node2D

@export var all_cards: Array[CardData]
@export var target_marker: Marker2D
@export var card_scene: PackedScene

var is_in_center = false
var start_position: Vector2
var start_scale: Vector2

var rarity_pools = {"Common": [], "Rare": [], "Epic": [], "Legendary": []}

var rarity_weights = {
	"Common": 60,
	"Rare": 25,
	"Epic": 10,
	"Legendary": 5
}

func _ready():
	start_position = global_position
	start_scale = scale
	for card in all_cards:
		if card.rarity in rarity_pools:
			rarity_pools[card.rarity].append(card)


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
	return_to_start()
	var draft_zone = %DraftZone
	draft_zone.visible = true
	
	var pulled_cards: Array[CardData] = []
	
	for i in range(amount):
		var card = _get_random_card()
		pulled_cards.append(card)
		print("Выпала карта: ", card.card_name, " [", card.rarity, "]")
	
	for data in pulled_cards:
		var new_card = card_scene.instantiate()
		draft_zone.add_child(new_card)
		new_card.setup_choice_mode(data)
		new_card.position = Vector2.ZERO - (new_card.size / 2)
		
	return pulled_cards

func _get_random_card() -> CardData:
	var roll = randf() * 100.0
	var cumulative = 0.0
	
	# Проходим по редкостям от редких к частым
	for rarity in ["Legendary", "Epic", "Rare", "Common"]:
		cumulative += rarity_weights[rarity]
		if roll <= cumulative:
			if not rarity_pools[rarity].is_empty():
				return rarity_pools[rarity].pick_random()
	
	return all_cards.pick_random() # Резервный вариант
