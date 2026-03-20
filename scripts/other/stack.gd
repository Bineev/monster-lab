extends Area2D


class_name Stack


@export var cards : Array[Card]
@export var production_card : Card
@export var is_can_product : bool


func add_card(card : Card):
	cards.append(card)
	card.reparent(self)
	card.stack = self
	card.change_state(DataManager.CardState.IN_STACK)


func remove_card(card : Card):
	cards.erase(card)
	card.reparent(GameManager.level)
	if cards.size() == 1:
		close_stack()


func calculate():
	if cards.size() < 2:
		return
	align_ordering()
	change_collision()
	align_cards()
	if cards[0].card_type == DataManager.CardType.PRODUCTION:
		production_card = cards[0]
		is_can_product = check_possible_production(production_card)
		if is_can_product:
			start_production()


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
		card.change_collision_to_stacked_state()
	cards[cards.size() - 1].input_pickable = true
	#if cards.size() == 1:
		#cards[0].change_collision_to_stacked_state()
	


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


func close_stack():
	print('close stack')
	for card in cards:
		if card and is_instance_valid(card):
			card.input_pickable = true
			card.change_state(DataManager.CardState.ON_FIELD)
			remove_card(card)
	queue_free()
