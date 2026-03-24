extends Node


enum CardState {
	APPEARS, ON_FIELD, DRAGGED, HOVER_STACK, ENTER_STACK, IN_STACK, EXIT_STACK, DESTROYED
}

enum CardType {
	PRODUCTION, LOCATION, MONSTER_PART, MONSTER, ENVIRONMENT, RES, ITEM, RECEPT
}

enum OwnerType {
	PLAYER, ENEMY, NEUTRAL
}

enum MonsterPartType {
	HAND, HEAD, FOOT, BODY, TAIL
}

enum EntityGrade {
	T1, T2, T3
}

enum GeneType {
	TOXIC, FLYING, SPECTER
}

enum ProductionType {
	PART_CREATOR, RES_CREATOR, MONSTER_CREATOR, MONSTER_MERGER
}

enum LocationType {
	GRAVEYARD, DARK_FARM, MYCELIUM
}

enum PercType {
	NONE, DIGGER, FIGHTER
}

enum MonsterFamily {
	BONES, ANIMAL, HUMAN, GHOUL
}


var card_header_size : float = 18

var default_z_index : int = 5

var parts_size : int = 4

var monster_love_size : int = 2

var chances_dict : Dictionary[EntityGrade, float] = {
	EntityGrade.T1 : 0.1,
	EntityGrade.T2 : 0.3,
	EntityGrade.T3 : 1
}
