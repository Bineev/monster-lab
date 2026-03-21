extends Node

@export var monster_scene : PackedScene = preload("res://scenes/card_actor_monster.tscn")
@export var grandpa_res : MonsterRes = preload("res://resources/monster_grandpa.tres")


func create_random_monster():
	pass


func create_monster_by_family_and_grade():
	pass


func create_monster_by_parts(parts : Array[PartRes]):
	pass


func create_grandpa():
	var grandpa : CardActorMonster = monster_scene.instantiate()
	grandpa.monster_res = grandpa_res
	GameManager.level.player_actors.add_child(grandpa)
	grandpa.initialize()
	grandpa.global_position = Vector2(200, 200)
	
