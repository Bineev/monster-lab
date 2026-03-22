extends Area2D


class_name Card

@export var stack_scene : PackedScene
@export var is_dragging : bool
@export var stack : Stack
@export var intersected_card : Card
@export var is_in_stack : bool
@export var card_state : DataManager.CardState
@export var prev_state : DataManager.CardState
@export var offset : Vector2 = Vector2.ZERO
@export var prev_z_index : int
@export var card_type : DataManager.CardType
@export var card_grade : DataManager.EntityGrade
@export var card_texture : Texture2D

@onready var collision_card: CollisionShape2D = %collision_card
@onready var anim_card: AnimationPlayer = %anim_card
@onready var activate_timer: Timer = %activate_timer
@onready var rect_main_img: TextureRect = %rect_main_img
@onready var label_header: Label = %label_header


func _ready() -> void:
	change_state(DataManager.CardState.APPEARS)


func change_state(new_state : DataManager.CardState):
	prev_state = card_state
	card_state = new_state
	match card_state:
		DataManager.CardState.APPEARS:
			anim_card.play('appears')
		DataManager.CardState.ON_FIELD:
			change_collision_to_stacked_state()
		DataManager.CardState.DRAGGED:
			if prev_state == DataManager.CardState.IN_STACK and not (stack and stack.is_dragging):
				stack.remove_card(self)
				#stack.calculate()
				is_in_stack = false
			change_collision_to_dragged_state()
			z_index = 100
		DataManager.CardState.HOVER_STACK:
			pass
		DataManager.CardState.ENTER_STACK:
			change_collision_to_stacked_state()
			enter_to_stack()
		DataManager.CardState.IN_STACK:
			is_in_stack = true
			stack.calculate()
			intersected_card = null
		DataManager.CardState.EXIT_STACK:
			pass
		DataManager.CardState.DESTROYED:
			pass
	print(DataManager.CardState.keys()[card_state] + ' ' + self.name)


func drop_card():
	if card_state == DataManager.CardState.HOVER_STACK:
		change_state(DataManager.CardState.ENTER_STACK)
	else:
		change_state(DataManager.CardState.ON_FIELD)
		z_index = DataManager.default_z_index


func _on_area_entered(area: Area2D) -> void:
	# здесь добавить чек на стак, если будут баги
	if card_state == DataManager.CardState.HOVER_STACK or not card_state == DataManager.CardState.DRAGGED:
		return
	intersected_card = area
	change_state(DataManager.CardState.HOVER_STACK)
	if not stack:
		stack = intersected_card.stack


func _on_area_exited(area: Area2D) -> void:
	if not card_state == DataManager.CardState.HOVER_STACK or card_state == DataManager.CardState.DRAGGED:
		return
	intersected_card = area
	# здесь ошибка
	if not is_in_stack:
		stack = null
	change_state(DataManager.CardState.DRAGGED)


func make_card_stacked():
	is_in_stack = true
	change_collision_to_stacked_state()


func make_card_unstacked():
	is_in_stack = false
	change_collision_to_dragged_state()


func change_collision_to_stacked_state():
	# кто проверяет?
	set_collision_layer_value(2, true)
	set_collision_mask_value(2, false)


func change_collision_to_dragged_state():
	set_collision_layer_value(2, false)
	set_collision_mask_value(2, true)


func change_collision_to_invisible_state():
	set_collision_layer_value(2, false)
	set_collision_mask_value(2, false)
	
	
func enter_to_stack():
	if not stack or not is_instance_valid(stack):
		create_stack()
	else:
		stack.add_card(self)
		intersected_card = null


func _on_anim_card_animation_finished(anim_name: StringName) -> void:
	pass
	#match anim_name:
		#'appears':
			#change_state(DataManager.CardState.ON_FIELD)


#func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	#if card_state == DataManager.CardState.APPEARS or card_state == DataManager.CardState.ENTER_STACK:
		#return
	## Проверяем, нажата ли левая кнопка мыши
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#print('dragged')
			#is_dragging = event.pressed
			#if not is_dragging:
				#check_drop()
			#else:
				#change_state(DataManager.CardState.DRAGGED)
	#
	## Если мышь движется и мы "тащим" карту
	#elif event is InputEventMouseMotion and is_dragging:
		## Перемещаем карту на величину движения мыши
		#position += event.relative

func _on_input_event(_viewport, event, _shape_idx):
	if GameManager.is_captured:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Начинаем перетаскивание и запоминаем смещение мыши относительно центра
			GameManager.is_captured = true
			change_state(DataManager.CardState.DRAGGED)
			is_dragging = true
			offset = global_position - get_global_mouse_position()
		else:
			# Отпускаем объект
			if card_state == DataManager.CardState.DRAGGED or card_state == DataManager.CardState.HOVER_STACK:
				print(self.name + ' dropped')
				is_dragging = false
				GameManager.is_captured = false
				drop_card()


func _input(event):
	if is_dragging and event is InputEventMouseMotion:
		# Обновляем позицию объекта с учетом смещения
		global_position = get_global_mouse_position() + offset
	
	# Страховка: если кнопка мыши отпущена за пределами Area2D
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		is_dragging = false
		GameManager.is_captured = false
		#drop_card()


func create_stack():
	print('create stack working')
	stack = stack_scene.instantiate()
	GameManager.level.add_child(stack)
	stack.global_position = intersected_card.global_position
	intersected_card.input_pickable = false
	self.input_pickable = false
	intersected_card.stack = stack
	# здесь цимес
	intersected_card.change_state(DataManager.CardState.ENTER_STACK)
	stack.add_card(self)
	intersected_card = null


func merge_stacks():
	# значит у нас уже стек
	# если у карты пересечения есть стек
	if intersected_card.stack:
		# мерджим стеки
		var copy_stack : Stack = stack
		for card in stack.cards: 
			intersected_card.stack.add_card(card)
		copy_stack.queue_free()
	else:
		# если карта одиночка, то добавляем ее в свои стек
		stack.global_position = intersected_card.global_position
		stack.add_card(intersected_card, true)


func get_size():
	return collision_card.shape.size


func _on_mouse_entered() -> void:
	if card_state == DataManager.CardState.ON_FIELD:
		var tween : Tween = create_tween()
		tween.tween_property(self, "scale",  Vector2(1.05, 1.05), 0.1)


func _on_mouse_exited() -> void:
	var tween : Tween = create_tween()
	tween.tween_property(self, "scale",  Vector2(1, 1), 0.1)
