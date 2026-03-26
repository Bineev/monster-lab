extends Area2D

class_name ShopLot


@export var lot : Card
@export var lot_cost : int
@export var lot_offset : float = 10

@onready var button_buy: Button = %button_buy


func initialize():
	await get_tree().process_frame
	lot_cost = lot.card_cost
	button_buy.text = str(lot_cost)
	global_position = lot.global_position - Vector2(0, lot_offset * 5)


func set_lot(new_lot : Card):
	lot = new_lot


func _on_button_buy_pressed() -> void:
	if PlayerManager.check_gold(lot_cost):
		button_buy.disabled = true
		SignalManager.on_spend_gold.emit(lot_cost)
		SignalManager.on_buy_lot.emit(lot)
		hide()
	get_tree().create_timer(0.1).timeout.connect(queue_free)
		
