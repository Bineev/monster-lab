extends Card

class_name CardLocation


@export var location_res : LocationRes
@export var location_type : DataManager.LocationType
@export var location_name : String
@export var location_desc : String
@export var location_loot : Array[Resource]
@export var digg_speed : float = 5
@export var res_count : int = 5
@export var digger : Card
@export var digg_in_process : bool


func initialize():
	await get_tree().process_frame
	card_type = location_res.card_type
	card_texture = location_res.card_texture
	card_grade = location_res.card_grade
	location_name = location_res.card_name
	location_desc = location_res.card_desc
	digg_speed = location_res.activate_speed
	res_count = location_res.use_count
	location_loot = location_res.loot_pool
	activate_timer.wait_time = digg_speed
	
	label_header.text = location_name
	rect_main_img.texture = card_texture


func set_digger(new_digger : CardActorMonster):
	digger = new_digger
	check_digger_type()


func check_digger_type():
	match digger.monster_perc:
		DataManager.PercType.DIGGER:
			activate_timer.wait_time = digg_speed * 0.8


func digg():
	activate_timer.start()
	digg_in_process = true


func stop_digg():
	activate_timer.paused = true


func continue_digg():
	activate_timer.paused = false


func _on_activate_timer_timeout() -> void:
	res_count -= 1
	get_loot()
	digg_in_process = false
	print('digg done ' + str(res_count))
	if res_count == 0:
		activate_timer.stop()
		destroy()


func destroy():
	if stack and is_instance_valid(stack):
		stack.remove_card(self)
	var tween = create_tween()
	tween.tween_callback(queue_free).set_delay(0.3)


func get_loot():
	if location_loot.size() == 0:
		print('loot is empty')
		return
	var rand : float = randf()
	var loot_res : Resource
	if rand <= DataManager.chances_dict[DataManager.EntityGrade.T1]:
		loot_res = location_loot[0]
	elif rand <= DataManager.chances_dict[DataManager.EntityGrade.T2]:
		loot_res = location_loot[1]
	elif rand <= DataManager.chances_dict[DataManager.EntityGrade.T3]:
		loot_res = location_loot[2]
	var loot_scene : PackedScene = EntityManager.create_entity_scene(loot_res)
	var loot : Card = loot_scene.instantiate()
	GameManager.level.player_loot.add_child(loot)
	loot.initialize()
	var pos : Vector2 = global_position + Vector2(randi_range(80, 100), randi_range(80, 100)) if randf() < 0.5 else global_position + Vector2(randi_range(-80, -100), randi_range(-80, -100))
	loot.global_position += pos 
