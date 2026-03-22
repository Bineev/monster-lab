extends Area2D


class_name Stack


@export var cards : Array[Card]
@export var production_card : Card
@export var location_card : CardLocation
@export var is_can_product : bool
@export var is_can_digg : bool
@export var is_dragging : bool
@export var offset : Vector2 = Vector2.ZERO

@onready var collision_stack: CollisionShape2D = %collision_stack


func create_collision():
	#var rect_coll : CollisionShape2D = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(cards[0].get_size().x, DataManager.card_header_size)
	return shape


func add_card(card : Card, is_in_start : bool = false):
	stop_production()
	if not is_in_start:
		cards.append(card)
	else:
		cards.push_front(card)
	card.reparent(self)
	card.stack = self
	card.change_state(DataManager.CardState.IN_STACK)


func remove_card(card : Card):
	stop_production()
	cards.erase(card)
	card.reparent(GameManager.level)
	if cards.size() < 2:
		close_stack()
	else:
		calculate()


func calculate():
	if cards.size() < 2:
		collision_stack.shape = create_collision()
		collision_stack.position.x += collision_stack.shape.size.x / 2
		collision_stack.position.y += collision_stack.shape.size.y / 2
		return
	align_ordering()
	change_collision()
	align_cards()

	match cards[0].card_type:
		DataManager.CardType.PRODUCTION:
			production_card = cards[0]
			is_can_product = check_possible_production(production_card)
			if is_can_product:
				start_production()
		DataManager.CardType.LOCATION:
			location_card = cards[0]
			is_can_digg = check_possible_digging(location_card)
			if is_can_digg:
				start_digging()


func check_possible_digging(card : Card):
	var content_cards : Array[Card] = cards.slice(1)
	if content_cards.size() == 1 and content_cards[0].card_type == DataManager.CardType.MONSTER:
		return true
	return false 


func align_ordering():
	var base_ordering : int = 5
	for card in cards:
		card.z_index = base_ordering
		base_ordering += 1


func align_cards():
	var offset : Vector2 = Vector2.ZERO
	for card in cards:
		card.position = offset
		offset += Vector2(0, DataManager.card_header_size)


func change_collision():
	for card in cards:
		card.input_pickable = false
		card.change_collision_to_invisible_state()
	cards[cards.size() - 1].input_pickable = true
	cards[cards.size() - 1].change_collision_to_stacked_state()


func check_possible_production(card : Card):
	var content_cards : Array[Card] = cards.slice(1)
	match card.production_type:
		DataManager.ProductionType.PART_CREATOR:
			for content_card in content_cards:
				if content_card.card_type != DataManager.CardType.MONSTER_PART:
					return false
			return true
		DataManager.ProductionType.MONSTER_CREATOR:
			pass
		DataManager.ProductionType.MONSTER_MERGER:
			pass
		DataManager.ProductionType.RES_CREATOR:
			pass


func start_production():
	'Production started'


func stop_production():
	'Production stopped'


func start_digging():
	location_card.set_digger(cards[1])
	location_card.digg()


func continue_digging():
	location_card.continue_digging()


func stop_digging():
	location_card.stop_digging()


func close_stack():
	print('close stack')
	for card in cards:
		if card and is_instance_valid(card):
			card.input_pickable = true
			cards.erase(card)
			card.reparent(GameManager.level)
			card.change_state(DataManager.CardState.ON_FIELD)
	queue_free()


func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Начинаем перетаскивание и запоминаем смещение мыши относительно центра
			is_dragging = true
			offset = global_position - get_global_mouse_position()
			cards[cards.size() - 1].change_state(DataManager.CardState.DRAGGED)
			z_index = 100
		else:
			# Отпускаем объект
			var active_card : Card = cards[cards.size() - 1]
			if active_card.intersected_card:
				active_card.merge_stacks()
			active_card.change_state(DataManager.CardState.IN_STACK)
			is_dragging = false
			z_index = 0
			#cards[cards.size() - 1].change_state(DataManager.CardState.IN_STACK)


func _input(event):
	if is_dragging and event is InputEventMouseMotion:
		# Обновляем позицию объекта с учетом смещения
		global_position = get_global_mouse_position() + offset
	
	# Страховка: если кнопка мыши отпущена за пределами Area2D
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		is_dragging = false
		#drop_card()
