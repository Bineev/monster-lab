extends ActorRes

class_name NPCRes


@export var npc_type : DataManager.NPCType
@export var npc_quest_name : String
@export var npc_quest_desc : String
@export var replics : Array[String]
# косяк с присваиванием массивов при создании NPC
@export var npc_quest_part_conditions : Array[DataManager.MonsterPartType]
@export var npc_quest_grade_conditions : DataManager.EntityGrade
@export var npc_quest_family_conditions : Array[DataManager.MonsterFamily]
@export var npc_shop_content : Array[CardRes]
@export var ncp_shop_lots_count : int
@export var npc_mood : DataManager.OwnerType
@export var npc_wait_timer : float
