extends Node

var location_scene : PackedScene = load("res://scenes/card_location.tscn")
var monster_scene : PackedScene = load("res://scenes/card_actor_monster.tscn")


func create_entity_scene(res : CardRes):
	match res.card_type:
		DataManager.CardType.LOCATION:
			var location : CardLocation = location_scene.instantiate()
			location.location_res = res
			var scene : PackedScene = PackedScene.new()
			scene.pack(location)
			return scene
		DataManager.CardType.MONSTER:
			var monster : CardActorMonster = monster_scene.instantiate()
			monster.monster_res = res
			var scene : PackedScene = PackedScene.new()
			scene.pack(monster)
			return scene
