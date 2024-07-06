extends Resource

class_name Region

@export var name: String
@export var levels: Array[String]
@export var unlock_condition: String
@export var region_specific_mutation: MutatedEnemy.MutationType
@export var boss_level: String

func _init(_name: String = "", _levels: Array = [], _unlock_condition: String = "", _region_specific_mutation: MutatedEnemy.MutationType = MutatedEnemy.MutationType.NONE, _boss_level: String = ""):
    name = _name
    levels = _levels
    unlock_condition = _unlock_condition
    region_specific_mutation = _region_specific_mutation
    boss_level = _boss_level

func is_unlocked(game_progress: Dictionary) -> bool:
    # Implement unlock logic based on game progress
    # This could check for completion of specific levels, collection of certain items, etc.
    match unlock_condition:
        "start":
            return true
        "gremland_completed":
            return "gremland_outskirts" in game_progress.completed_levels
        "wild_wilds_completed":
            return "wild_wilds_temples" in game_progress.completed_levels
        "suburbia_completed":
            return "suburbia_caverns" in game_progress.completed_levels
        "retro_arcade_completed":
            return "retro_arcade_mainframe" in game_progress.completed_levels
        "neon_city_completed":
            return "neon_city_skyline" in game_progress.completed_levels
        "bionic_zoo_completed":
            return "bionic_zoo_future" in game_progress.completed_levels
        "aqua_depths_completed":
            return "aqua_depths_deep_sea" in game_progress.completed_levels
        "cosmic_voyage_completed":
            return "cosmic_voyage_space_ship" in game_progress.completed_levels
        _:
            return false

func get_first_level() -> String:
    return levels[0] if levels.size() > 0 else ""

func get_next_level(current_level: String) -> String:
    var index = levels.find(current_level)
    if index != -1 and index < levels.size() - 1:
        return levels[index + 1]
    return ""

func is_boss_level(level: String) -> bool:
    return level == boss_level
