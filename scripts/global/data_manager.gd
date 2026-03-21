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
	DIGGER, FIGHTER
}

enum MonsterFamily {
	BONES, ANIMAL, HUMAN
}


var card_header_size : float = 20

var default_z_index : int = 5
