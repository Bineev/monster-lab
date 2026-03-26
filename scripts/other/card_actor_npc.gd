extends CardActor

class_name CardActorNPC


@export var lot_scene : PackedScene = preload("res://scenes/shop_lot.tscn")
@export var npc_res : NPCRes
@export var npc_type : DataManager.NPCType
@export var npc_quest_name : String
@export var npc_quest_desc : String
@export var replics : Array[String]
@export var quest_part_conditions : Array[DataManager.MonsterPartType]
@export var quest_grade_conditions : DataManager.EntityGrade
@export var quest_family_conditions : Array[DataManager.MonsterFamily]
@export var npc_shop_content : Array[CardRes]
@export var ncp_shop_lots_count : int
@export var npc_mood : DataManager.OwnerType
@export var npc_wait_timer : float
@export var lots : Array[Card]
@export var lots_offset : float = 20

func initialize():
	await get_tree().process_frame
	SignalManager.on_buy_lot.connect(buy_lot)
	card_owner_type = npc_res.card_owner_type
	card_cost = npc_res.card_cost
	npc_type = npc_res.npc_type
	actor_name = npc_res.card_name
	actor_desc = npc_res.card_desc
	actor_damage = npc_res.actor_damage
	actor_health = npc_res.actor_health
	card_texture = npc_res.card_texture
	npc_quest_name = npc_res.npc_quest_name 
	npc_quest_desc = npc_res.npc_quest_desc 
	replics = npc_res.replics 
	quest_part_conditions = npc_res.quest_part_conditions 
	quest_grade_conditions = npc_res.quest_grade_conditions 
	quest_family_conditions = npc_res.quest_family_conditions 
	npc_shop_content = npc_res.npc_shop_content 
	ncp_shop_lots_count = npc_res.ncp_shop_lots_count 
	npc_mood = npc_res.npc_mood 
	npc_wait_timer = npc_res.npc_wait_timer 
	
	label_header.text = actor_name
	rect_main_img.texture = card_texture
	panel_back.tooltip_text = actor_desc
	label_damage.text = str(actor_damage)
	label_health.text = str(actor_health)
	setup_tooltip()
	activate()


func activate():
	match npc_type:
		DataManager.NPCType.TRADER:
			create_shop()


func create_shop():
	if npc_shop_content.size() == 0:
		return
	# пока просто вываливаем контент
	for content in npc_shop_content:
		var copy_res : Resource = content.duplicate(true)
		copy_res.card_owner_type = DataManager.OwnerType.NEUTRAL
		var content_scene : PackedScene = EntityManager.create_entity_scene(copy_res)
		var lot : Card = content_scene.instantiate()
		GameManager.level.add_child(lot)
		lot.initialize()
		lots.append(lot)
	align_lots()


func align_lots():
	var total_lots_size : float = lots.size() * lots[0].get_size().x + (lots.size() - 1) * lots_offset
	var starting_position : Vector2 = Vector2(global_position.x - total_lots_size / 2 + lots[0].get_size().x / 2, global_position.y + lots[0].get_size().y + lots_offset * 3)
	var new_offset : Vector2 = Vector2(0, 0)
	for lot in lots:
		lot.global_position = starting_position + new_offset
		var shop_lot : ShopLot = lot_scene.instantiate()
		GameManager.level.add_child(shop_lot)
		shop_lot.set_lot(lot)
		shop_lot.initialize()
		new_offset += Vector2(lots[0].get_size().x + lots_offset, 0)


func buy_lot(lot : Card):
	if npc_type != DataManager.NPCType.TRADER:
		return
	if not lots.has(lot):
		return
	lot.card_owner_type = DataManager.OwnerType.PLAYER
	lots.erase(lot)
	if lots.size() == 0:
		queue_free()
