extends Node2D

class_name Level

@onready var player_actors: Node2D = %player_actors


func _ready() -> void:
	GameManager.level = self
	MonsterManager.create_grandpa()
