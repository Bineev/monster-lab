extends CardActor

class_name CardActorMonster


@export var monster_res : MonsterRes
@export var monster_perc : DataManager.PercType
@export var monster_parts : Array[PartRes]


func initialize():
	await get_tree().process_frame
	card_type = monster_res.card_type
	card_texture = monster_res.card_texture
	card_grade = monster_res.card_grade
	actor_name = monster_res.card_name
	actor_desc = monster_res.card_desc
	actor_health = monster_res.actor_health
	actor_damage = monster_res.actor_damage
	card_texture = monster_res.card_texture
	monster_parts = monster_res.monster_parts
	monster_perc = monster_res.monster_perc
	
	label_header.text = actor_name
	rect_main_img.texture = card_texture
	label_damage.text = str(actor_damage)
	label_health.text = str(actor_health)
