extends Node

@export var monster_scene : PackedScene = preload("res://scenes/card_actor_monster.tscn")
@export var grandpa_res : MonsterRes = preload("res://resources/monster_grandpa.tres")

@export var ghoul_part_reses : Array[PartRes] = [
	preload("res://resources/part_body_zobmie.tres"),
	preload("res://resources/part_lhand_zombie.tres"),
	preload("res://resources/part_rhand_zombie.tres"),
	preload("res://resources/part_foot_zombie.tres"),
	preload("res://resources/part_head_zombie.tres"),
]

func create_random_monster():
	pass


func create_part_by_family_and_grade_and_type(part_family : DataManager.MonsterFamily, part_grade : DataManager.EntityGrade, part_type : DataManager.MonsterPartType):
	var parts_pool : Array[PartRes]
	match part_family:
		DataManager.MonsterFamily.GHOUL:
			parts_pool = ghoul_part_reses
	var new_part : PartRes
	for part in parts_pool:
		if part.part_type == part_type:
			new_part = part.duplicate(true)
	if part_grade < DataManager.max_grade:
		new_part.card_grade = part_grade + 1
	return new_part


func create_grade_up_part(parts : Array[PartRes]):
	if parts.size() < DataManager.parts_merger_count:
		return
	var part_grade : DataManager.EntityGrade = parts.pick_random().card_grade
	var part_family : DataManager.MonsterFamily = parts.pick_random().part_family
	var part_type : DataManager.MonsterPartType = parts.pick_random().part_type
	var part_res : PartRes = create_part_by_family_and_grade_and_type(part_family, part_grade, part_type)
	return part_res


func create_monster_by_parts(parts : Array[PartRes]):
	var body_res : PartRes
	var head_res : PartRes
	var rhand_res : PartRes
	var foot_res : PartRes
	var lhand_res : PartRes
	var total_health : int
	var total_damage : int
	var percs : Array[DataManager.PercType]
	var families : Array[DataManager.MonsterFamily]
	for part in parts:
		match part.part_type:
			DataManager.MonsterPartType.BODY:
				body_res = part
			DataManager.MonsterPartType.HEAD:
				head_res = part
			DataManager.MonsterPartType.FOOT:
				foot_res = part
			DataManager.MonsterPartType.RHAND:
				rhand_res = part
			DataManager.MonsterPartType.LHAND:
				lhand_res = part
		percs.append(part.part_perc)
		families.append(part.part_family)
		total_health += part.actor_health
		total_damage += part.actor_damage
	var new_res : MonsterRes = MonsterRes.new()
	new_res.actor_damage = total_damage
	new_res.actor_health = total_health
	new_res.monster_families.append(families.pick_random())
	new_res.monster_perc = percs.pick_random() if percs.size() > 0 else DataManager.PercType.NONE
	new_res.card_name = 'мутант'
	new_res.card_desc = 'Странное создание. Надо найти ему применение или продать к чертям'
	new_res.monster_body_texture = body_res.card_texture
	new_res.monster_lhand_texture = lhand_res.card_texture
	new_res.monster_rhand_texture = rhand_res.card_texture
	new_res.monster_foot_texture = foot_res.card_texture
	new_res.monster_head_texture = head_res.card_texture
	new_res.monster_parts.append(body_res)
	new_res.monster_parts.append(lhand_res)
	new_res.monster_parts.append(foot_res)
	new_res.monster_parts.append(rhand_res)
	new_res.monster_parts.append(head_res)
	new_res.card_type = DataManager.CardType.MONSTER
	new_res.card_grade = parts.pick_random().card_grade
	
	return new_res


func create_monster_by_monsters(monsters : Array[CardActorMonster]):
	var perc : DataManager.PercType
	monsters.shuffle()
	for monster in monsters:
		if monster.monster_perc != DataManager.PercType.NONE:
			perc = monster.monster_perc
			break
	var aggregate_parts : Array[PartRes]
	for monster in monsters:
		aggregate_parts.append_array(monster.monster_parts)
	aggregate_parts.shuffle()
	var final_part_reses : Array[PartRes]
	var body_res : PartRes
	var lhand_res : PartRes
	var rhand_res : PartRes
	var foot_res : PartRes
	var head_res : PartRes
	var is_already_has_body : bool
	var is_already_has_lhand : bool
	var is_already_has_rhand : bool
	var is_already_has_foot : bool
	var is_already_has_head : bool
	for part in aggregate_parts:
		if part.part_type == DataManager.MonsterPartType.BODY:
			if not is_already_has_body:
				final_part_reses.append(part)
				is_already_has_body = true
		elif part.part_type == DataManager.MonsterPartType.LHAND:
			if not is_already_has_lhand:
				final_part_reses.append(part)
				is_already_has_lhand = true
		elif part.part_type == DataManager.MonsterPartType.RHAND:
			if not is_already_has_rhand:
				final_part_reses.append(part)
				is_already_has_rhand = true
		elif part.part_type == DataManager.MonsterPartType.FOOT:
			if not is_already_has_foot:
				final_part_reses.append(part)
				is_already_has_foot = true
		elif part.part_type == DataManager.MonsterPartType.HEAD:
			if not is_already_has_head:
				final_part_reses.append(part)
				is_already_has_head = true
	var monster_res : MonsterRes = create_monster_by_parts(final_part_reses)
	return monster_res


func create_grandpa():
	var grandpa : CardActorMonster = monster_scene.instantiate()
	grandpa.monster_res = grandpa_res
	GameManager.level.player_actors.add_child(grandpa)
	grandpa.initialize()
	grandpa.global_position = Vector2(200 + randi_range(-150, 150), 200 + randi_range(-150, 150))
	
