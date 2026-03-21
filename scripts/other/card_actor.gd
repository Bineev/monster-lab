extends Card

class_name CardActor


@export var actor_name : String
@export var actor_desc : String
@export var actor_health : String
@export var actor_damage : String

@onready var label_damage: Label = %label_damage
@onready var label_health: Label = %label_health


func move():
	pass


func fight():
	pass
