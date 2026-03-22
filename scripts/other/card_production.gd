extends Card

class_name CardProduction


@export var production_res : ProductionRes
@export var production_type : DataManager.ProductionType
@export var production_name : String
@export var production_desc : String
@export var product_speed : float
@export var product_count : int
@export var remaining_product_count : int
@export var is_product_in_progress : bool
@export var parts : Array[CardActorPart]


@onready var label_uses: Label = %label_uses


func initialize():
	await get_tree().process_frame
	card_type = production_res.card_type
	card_texture = production_res.card_texture
	card_grade = production_res.card_grade
	production_name = production_res.card_name
	production_desc = production_res.card_desc
	product_speed = production_res.activate_speed
	product_count = production_res.use_count
	activate_timer.wait_time = product_speed
	
	label_header.text = production_name
	rect_main_img.texture = card_texture
	remaining_product_count = product_count
	update_res_count_ui()


func _process(delta: float) -> void:
	if stack:
		stack.update_progress_bar(activate_timer.wait_time - activate_timer.time_left)


func update_res_count_ui():
	label_uses.text = '%s/%s' % [remaining_product_count, product_count]


func product():
	stack.activation_progress.max_value = activate_timer.wait_time
	activate_timer.start()
	is_product_in_progress = true


func stop_product():
	activate_timer.paused = true


func continue_product():
	stack.activation_progress.max_value = activate_timer.wait_time
	activate_timer.paused = false


func _on_activate_timer_timeout() -> void:
	remaining_product_count -= 1
	update_res_count_ui()
	create()
	if remaining_product_count == 0:
		activate_timer.stop()
		destroy()


func set_parts(new_parts : Array[CardActorPart]):
	parts = new_parts


func destroy():
	if stack and is_instance_valid(stack):
		stack.remove_card(self)
	var tween = create_tween()
	tween.tween_callback(queue_free).set_delay(0.3)


func create():
	match production_type:
		DataManager.ProductionType.MONSTER_CREATOR:
			var part_reses : Array[PartRes]
			for part in parts:
				part_reses.append(part)
				
			var monster_res : MonsterRes = MonsterManager.create_monster_by_parts(part_reses)
			var monster_scene : PackedScene = EntityManager.create_entity_scene(monster_res)
			var monster : CardActorMonster = monster_scene.instantiate()
			GameManager.level.player_actors.add_child(monster)
			monster.initialize()
			var pos : Vector2 = global_position + Vector2(randi_range(80, 100), randi_range(80, 100)) if randf() < 0.5 else global_position + Vector2(randi_range(-80, -100), randi_range(-80, -100))
			monster.global_position += pos 
	
