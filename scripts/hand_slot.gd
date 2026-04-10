extends Control

@export var spread_curve: float = 40.0 # Насколько сильно карты расходятся по горизонтали
@export var height_curve: float = 15.0 # Насколько сильно выгибается дуга (вверх-вниз)
@export var rotation_curve: float = 0.05 # Насколько сильно наклоняются карты (в радианах)
@export var max_hand_width: float = 350.0 # Максимальная ширина веера в пикселях
@export var min_spread: float = 50     # Минимальное расстояние между картами (плотно)
@export var max_spread: float = 80.0     # Максимальное расстояние (свободно)

func _ready():
	# Каждый раз, когда в руку добавляется карта, пересчитываем веер
	child_order_changed.connect(update_hand_positions)

func update_hand_positions():
	var cards = get_children()
	var card_count = cards.size()
	
	if card_count == 0:
		return
	
	var scaling_factor = pow(card_count, 0.8)
	var ideal_width = (card_count - 1) * max_spread
	
	var effective_spread = max_spread * (1.0 - (card_count * 0.1)) # -3% ширины за каждую карту
	effective_spread = clamp(effective_spread, min_spread, max_spread)
	
	var current_hand_width = min((card_count - 1) * effective_spread, max_hand_width)

	for i in range(card_count):
		var card = cards[i]
		
		# Вычисляем "индекс" карты от -1 до 1 (для симметрии)
		# Если карта одна, индекс будет 0.
		var hand_ratio = 0.5
		if card_count > 1:
			hand_ratio = float(i) / float(card_count - 1)
		
		# Смещаем диапазон так, чтобы 0 был центром (от -0.5 до 0.5)
		var offset = hand_ratio - 0.5
		
		# 1. Позиция по X (расстояние между картами)
		var x_pos = offset * current_hand_width
		
		# 2. Позиция по Y (создаем дугу через параболу: y = x^2)
		# Чем дальше карта от центра, тем она ниже
		var y_pos = abs(offset) * abs(offset) * height_curve * card_count * 1.2
		
		# 3. Поворот (Rotation)
		var angle = offset * rotation_curve * card_count
		
		# Применяем значения (используем Tween для плавности, если хочешь)
		card.position = Vector2(x_pos, y_pos)
		card.rotation = angle
		card.hand_rotation = angle
		card.base_y = y_pos
