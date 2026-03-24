extends Node2D

class_name Level

@onready var player_actors: Node2D = %player_actors
@onready var player_loot: Node2D = %player_loot
@onready var player_locations: Node2D = %player_locations


func _ready() -> void:
	GameManager.level = self
	MonsterManager.create_grandpa()
	MonsterManager.create_grandpa()
	MonsterManager.create_grandpa()
	LocationManager.create_graveyard()
	ProductionManager.create_stapler()
	ProductionManager.create_motel()
