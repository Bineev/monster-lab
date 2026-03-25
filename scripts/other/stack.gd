extends Area2D


class_name Stack


@export var cards : Array[Card]
@export var production_card : CardProduction
@export var location_card : CardLocation
@export var is_can_product : bool
@export var is_can_digg : bool
@export var is_dragging : bool
@export var offset : Vector2 = Vector2.ZERO
@export var has_body : bool
@export var has_hand : bool
@export var has_head : bool
@export var has_foot : bool
@export var parts : Array[CardActorPart]
@export var intersected_areas : Array[Card]
@export var stack_scene : PackedScene = preload('res://scenes/stack.tscn')

@onready var collision_stack: CollisionShape2D = %collision_stack
@onready var activation_progress: ProgressBar = %activation_progress
@onready var stack_to_card_collision: CollisionShape2D = %stack_to_card_collision
@onready var stack_area: Area2D = %stack_area


func create_collision():
	#var rect_coll : CollisionShape2D = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(cards[0].get_size().x, DataManager.card_header_size)
	return shape


func activate_stack_to_card_collision(is_active : bool):
	if is_active:
		stack_area.set_collision_mask_value(2, true)
	else:
		stack_area.set_collision_mask_value(2, false)


func create_stack_collision():
	var shape = RectangleShape2D.new()
	shape.size = Vector2(cards[0].get_size().x, (cards.size() - 1) * DataManager.card_header_size + cards[0].get_size().y)
	return shape


func add_card(card : Card, is_in_start : bool = false):
	stop_production()
	stop_digging()
	card.scale = Vector2(1, 1)
	if not is_in_start:
		cards.append(card)
	else:
		cards.push_front(card)
	card.reparent(self)
	card.stack = self
	card.change_state(DataManager.CardState.IN_STACK)


func remove_card(card : Card):
	stop_production()
	stop_digging()
	cards.erase(card)
	get_tree().process_frame.connect(card.reparent.bind(GameManager.level), CONNECT_ONE_SHOT)
	card.reparent(GameManager.level)
	if card.card_state != DataManager.CardState.DRAGGED:
		card.change_state(DataManager.CardState.ON_FIELD)
	if cards.size() < 2:
		call_deferred('close_stack')
	else:
		calculate()


func calculate():
	if cards.size() < 2:
		collision_stack.shape = create_collision()
		collision_stack.position.x += collision_stack.shape.size.x / 2
		collision_stack.position.y += collision_stack.shape.size.y / 2
		activation_progress.custom_minimum_size = Vector2(cards[0].get_size().x, DataManager.card_header_size)
		return
	stack_to_card_collision.shape = create_stack_collision()
	stack_to_card_collision.position.x = stack_to_card_collision.shape.size.x / 2
	stack_to_card_collision.position.y = stack_to_card_collision.shape.size.y / 2
	align_ordering()
	change_collision()
	align_cards()

	match cards[0].card_type:
		DataManager.CardType.PRODUCTION:
			production_card = cards[0]
			is_can_product = check_possible_production(production_card)
			if is_can_product and not production_card.is_product_in_progress:
				start_production()
			elif is_can_product and production_card.is_product_in_progress:
				continue_production()
		DataManager.CardType.LOCATION:
			location_card = cards[0]
			is_can_digg = check_possible_digging(location_card)
			if is_can_digg and not location_card.is_digg_in_progress:
				start_digging()
			elif is_can_digg and location_card.is_digg_in_progress:
				continue_digging()


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
			if content_cards.size() != DataManager.parts_size:
				return false
			for content_card in content_cards:
				if content_card.card_type != DataManager.CardType.MONSTER_PART:
					return false
				else:
					match content_card.part_type:
						DataManager.MonsterPartType.BODY:
							has_body = true
							var is_already_has_part : bool
							for part in parts:
								if part.part_type == DataManager.MonsterPartType.BODY:
									is_already_has_part = true
							if not is_already_has_part:
								parts.append(content_card)
						DataManager.MonsterPartType.LHAND:
							has_hand = true
							var is_already_has_part : bool
							for part in parts:
								if part.part_type == DataManager.MonsterPartType.LHAND:
									is_already_has_part = true
							if not is_already_has_part:
								parts.append(content_card)
						DataManager.MonsterPartType.RHAND:
							has_hand = true
							var is_already_has_part : bool
							for part in parts:
								if part.part_type == DataManager.MonsterPartType.RHAND:
									is_already_has_part = true
							if not is_already_has_part:
								parts.append(content_card)
						DataManager.MonsterPartType.FOOT:
							has_foot = true
							var is_already_has_part : bool
							for part in parts:
								if part.part_type == DataManager.MonsterPartType.FOOT:
									is_already_has_part = true
							if not is_already_has_part:
								parts.append(content_card)
						DataManager.MonsterPartType.HEAD:
							has_head = true
							var is_already_has_part : bool
							for part in parts:
								if part.part_type == DataManager.MonsterPartType.HEAD:
									is_already_has_part = true
							if not is_already_has_part:
								parts.append(content_card)
			if parts.size() == DataManager.parts_size:
				return true
			return false
		DataManager.ProductionType.MONSTER_CREATOR:
			if content_cards.size() != DataManager.monster_love_size:
				return false
			for content_card in content_cards:
				if content_card.card_type != DataManager.CardType.MONSTER:
					return false
				else:
					if not content_card.is_can_love:
						return false
			return true
		DataManager.ProductionType.MONSTER_MERGER:
			pass
		DataManager.ProductionType.RES_CREATOR:
			pass
		DataManager.ProductionType.PART_MERGER:
			if content_cards.size() != DataManager.parts_merger_count:
				return false
			if content_cards[0].card_type != DataManager.CardType.MONSTER_PART:
				return false
			var same_part_type : DataManager.MonsterPartType = content_cards[0].part_type
			for content_card in content_cards:
				if content_card.card_type != DataManager.CardType.MONSTER_PART:
					return false
				else:
					if same_part_type != content_card.part_type:
						return false
			return true


func start_production():
	if production_card and not production_card.is_product_in_progress:
		activation_progress.show()
		# раскоментировать, если хотим, чтобы карту нельзя было снять
		#cards[cards.size() - 1].input_pickable = false
		#cards[cards.size() - 1].change_collision_to_invisible_state()
		match production_card.production_type:
			DataManager.ProductionType.PART_CREATOR:
				production_card.set_parts(parts)
			DataManager.ProductionType.MONSTER_CREATOR:
				var monster_cards : Array[CardActorMonster]
				for card in cards.slice(1):
					monster_cards.append(card)
				production_card.set_monsters(monster_cards)
			DataManager.ProductionType.PART_MERGER:
				for card in cards.slice(1):
					var part : CardActorPart = card
					parts.append(part)
				production_card.set_parts(parts)
		production_card.product()


func stop_production():
	if production_card and production_card.is_product_in_progress:
		production_card.stop_product()


func continue_production():
	activation_progress.show()
	if production_card:
		production_card.continue_product()



func start_digging():
	activation_progress.show()
	location_card.set_digger(cards[1])
	location_card.digg()


func continue_digging():
	activation_progress.show()
	if location_card:
		location_card.continue_digg()


func stop_digging():
	activation_progress.hide()
	if location_card:
		location_card.stop_digg()


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
			#cards[cards.size() - 1].change_state(DataManager.CardState.DRAGGED)
			z_index = 100
			for card in cards:
				card.change_collision_to_invisible_state()
				card.input_pickable = false
			activate_stack_to_card_collision(true)
			intersected_areas.clear()
		else:
			# Отпускаем объект
			var intersected_card : Card = get_closest_card()
			if intersected_card:
				merge_stacks(intersected_card)
			is_dragging = false
			z_index = 0
			activate_stack_to_card_collision(false)
			if cards.size() >= 2:
					cards[cards.size() - 1].input_pickable = true
					cards[cards.size() - 1].change_collision_to_stacked_state()
			#cards[cards.size() - 1].change_state(DataManager.CardState.IN_STACK)


func _input(event):
	if is_dragging and event is InputEventMouseMotion:
		# Обновляем позицию объекта с учетом смещения
		global_position = get_global_mouse_position() + offset
	
	# Страховка: если кнопка мыши отпущена за пределами Area2D
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		is_dragging = false
		#drop_card()


func update_progress_bar(new_value : float):
	activation_progress.value = new_value


func _on_stack_area_area_entered(area: Area2D) -> void:
	var card : Card = area
	if not intersected_areas.has(card):
		intersected_areas.append(card)


func _on_stack_area_area_exited(area: Area2D) -> void:
	var card : Card = area
	if intersected_areas.has(card):
		intersected_areas.erase(card)


func get_closest_card():
	if intersected_areas.size() == 0:
		return null
	if intersected_areas.size() == 1:
		return intersected_areas[0]
	intersected_areas.sort_custom(func(a: Card, b: Card): return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position))
	return intersected_areas[0]


func merge_stacks(card : Card):
	var stack : Stack = stack_scene.instantiate()
	var cards_pool : Array[Card]
	if card.stack:
		cards_pool.append_array(card.stack.cards.duplicate(true))
		card.stack.queue_free()
	else:
		cards_pool.append(card)
	cards_pool.append_array(cards.duplicate())
	GameManager.level.add_child(stack)
	stack.global_position = card.global_position
	for new_card in cards_pool:
		stack.add_card(new_card)
	queue_free()
