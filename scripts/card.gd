extends Control

@export var card_data: CardData:
	set(value):
		card_data = value
		if is_inside_tree():
			update_view()

@onready var name_label: Label = $MarginContainer/VBoxContainer/NameLabel
@onready var description_label: Label = $MarginContainer/VBoxContainer/DescriptionLabel
@onready var power_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/PowerLabel
@onready var cost_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/CostLabel
@onready var health_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/HealthLabel

func _ready():
	update_view()

func update_view():
	if card_data == null:
		return
	
	name_label.text = card_data.card_name
	description_label.text = card_data.description
	power_label.text = "Atk: " + str(card_data.power)
	cost_label.text = "Mana: " + str(card_data.cost)
	health_label.text = "Health: " + str(card_data.health)
