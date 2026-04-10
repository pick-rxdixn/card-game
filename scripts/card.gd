extends Control

@export var card_data: CardData:
	set(value):
		card_data = value
		if is_inside_tree():
			update_view()

var hand_rotation: float = 0.1
var base_y: float = 0.0
var is_hovered: bool = false

@onready var name_label: Label = $Body/MarginContainer/VBoxContainer/NameLabel
@onready var description_label: Label = $Body/MarginContainer/VBoxContainer/DescriptionLabel
@onready var power_label: Label = $Body/MarginContainer/VBoxContainer/HBoxContainer/PowerLabel
@onready var cost_label: Label = $Body/MarginContainer/VBoxContainer/HBoxContainer/CostLabel
@onready var health_label: Label = $Body/MarginContainer/VBoxContainer/HBoxContainer/HealthLabel
@onready var take_button: Button = $Body/HBoxContainer/TakeButton
@onready var sell_button: Button = $Body/HBoxContainer/SellButton
@onready var mouse_detector: Control = $MouseDetector

func _ready():
	take_button.visible = false
	sell_button.visible = false
	update_view()

func update_view():
	if card_data == null:
		return
	
	name_label.text = card_data.card_name
	description_label.text = card_data.description
	power_label.text = "Atk: " + str(card_data.power)
	cost_label.text = "Mana: " + str(card_data.cost)
	health_label.text = "Health: " + str(card_data.health)

func setup_choice_mode(data: CardData):
	self.card_data = data
	scale = Vector2(1.5, 1.5)
	
	take_button.visible = true
	sell_button.visible = true
	
func _on_take_button_pressed():
	var hand = get_tree().root.find_child("HandSlot", true, false)
	take_button.visible = false
	sell_button.visible = false
	reparent(hand, false)
	_check_draft_zone_empty.call_deferred()


func _check_draft_zone_empty():
	var dz = get_tree().root.find_child("DraftZone", true, false)
	if dz.get_child_count() == 0:
		dz.visible = false


func _on_mouse_detector_mouse_entered() -> void:
	if get_parent().name == "HandSlot":
		is_hovered = true
		z_index = 10
		var target_y = -100.0 - base_y
		var tween = create_tween().set_parallel(true)
		tween.tween_property($Body, "rotation", -rotation, 0.1)
		tween.tween_property($Body, "position:y", target_y, 0.1)


func _on_mouse_detector_mouse_exited() -> void:
	if get_parent().name == "HandSlot":
		is_hovered = false
		z_index = 0
		var tween = create_tween().set_parallel(true)
		tween.tween_property($Body, "rotation", 0, 0.1)
		tween.tween_property($Body, "position:y", 0, 0.1)
		tween.tween_property(self, "rotation", hand_rotation, 0.1)
