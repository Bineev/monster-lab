extends Card

class_name CardLocation


@export var location_res : LocationRes
@export var location_type : DataManager.LocationType
@export var location_name : String
@export var location_desc : String
@export var location_loot : Array[Resource]
@export var digg_speed : float
@export var res_count : int
@export var remaining_res_count : int
@export var digger : Card
@export var is_digg_in_progress : bool


@onready var label_uses: Label = %label_uses


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
	panel_back.tooltip_text = location_desc
	setup_tooltip()
	
	label_header.text = location_name
	rect_main_img.texture = card_texture
	remaining_res_count = res_count
	update_res_count_ui()



func _process(delta: float) -> void:
	if stack:
		stack.update_progress_bar(activate_timer.wait_time - activate_timer.time_left)


func update_res_count_ui():
	label_uses.text = '%s/%s' % [remaining_res_count, res_count]


func set_digger(new_digger : CardActorMonster):
	digger = new_digger
	check_digger_type()


func check_digger_type():
	match digger.monster_perc:
		DataManager.PercType.DIGGER:
			activate_timer.wait_time = digg_speed * 0.8


func digg():
	stack.activation_progress.max_value = activate_timer.wait_time
	activate_timer.start()
	is_digg_in_progress = true


func stop_digg():
	activate_timer.paused = true


func continue_digg():
	stack.activation_progress.max_value = activate_timer.wait_time
	activate_timer.paused = false


func _on_activate_timer_timeout() -> void:
	remaining_res_count -= 1
	update_res_count_ui()
	get_loot()
	print('digg done ' + str(remaining_res_count))
	if remaining_res_count == 0:
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
		loot_res = location_loot.slice(2).pick_random()
	var loot_scene : PackedScene = EntityManager.create_entity_scene(loot_res)
	var loot : Card = loot_scene.instantiate()
	GameManager.level.player_loot.add_child(loot)
	loot.initialize()
	var pos : Vector2 = global_position + Vector2(randi_range(80, 100), randi_range(80, 100)) if randf() < 0.5 else global_position + Vector2(randi_range(-80, -100), randi_range(-80, -100))
	loot.global_position += pos 
