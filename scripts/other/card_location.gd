extends Card

class_name CardLocation


@export var location_res : Resource
@export var location_type : DataManager.LocationType
@export var location_grade : DataManager.EntityGrade
@export var location_name : String
@export var location_desc : String
@export var digg_speed : float = 5
@export var res_count : int = 5
@export var digger : Card
@export var digg_in_process : bool


func initialize(new_digger : Card):
	digger = new_digger
	check_digger_type()
	location_name = location_res.card_name
	location_desc = location_res.card_desc
	digg_speed = location_res.activate_speed
	res_count = location_res.use_count
	location_grade = location_res.card_grade
	activate_timer.wait_time = digg_speed


func check_digger_type():
	match digger.perc_type:
		DataManager.PercType.DIGGER:
			digg_speed *= 0.8


func digg():
	res_count -= 1
	activate_timer.start()
	digg_in_process = true


func stop_digg():
	activate_timer.paused = true


func continue_digg():
	activate_timer.paused = false

func _on_activate_timer_timeout() -> void:
	DiggManager.create_loot_by_location_and_grade(self, location_grade)
	digg_in_process = false
	if res_count == 0:
		activate_timer.stop()
		destroy()


func destroy():
	if stack and is_instance_valid(stack):
		stack.remove_card(self)
	var tween = create_tween()
	tween.tween_callback(queue_free).set_delay(0.3)
