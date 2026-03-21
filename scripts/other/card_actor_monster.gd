extends CardActor

class_name CardActorMonster


@export var monster_res : Resource
@export var monster_perc : DataManager.PercType
@export var monster_parts : Array[Resource]


func initialize():
	await get_tree().process_frame
	actor_name = monster_res.card_name
	actor_desc = monster_res.card_desc
	actor_health = monster_res.card_health
	actor_damage = monster_res.card_damage
	card_texture = monster_res.card_texture
	monster_parts = monster_res.monster_parts
	monster_perc = monster_res.monster_perc
	
	label_header.text = actor_name
	rect_main_img.texture = card_texture
