extends Node

signal level_loaded(level_name)
signal level_completed(level_name)
signal tool_unlocked(tool_type)
signal wearable_unlocked(wearable_type)
signal health_bonus_awarded
signal key_item_awarded(item_name)
signal moon_water_unlocked

enum ToolType { WHIP, SLINGSHOT, BOOMERANG, DRONE, GLIDER }
enum WearableType { POWER_GLOVES, BODYSUIT }

var current_level: String = ""
var current_region: Region

var regions: Dictionary = {
    "Gremland": Region.new("Gremland", ["gremland_village", "gremland_outskirts"], "start", MutatedEnemy.MutationType.EXPLOSION, "gremland_outskirts"),
    "Wild Wilds": Region.new("Wild Wilds", ["wild_wilds_jungle", "wild_wilds_temples"], "gremland_completed", MutatedEnemy.MutationType.TOXIC, "wild_wilds_temples"),
    "Suburbia Nights": Region.new("Suburbia Nights", ["suburbia_streets", "suburbia_caverns"], "wild_wilds_completed", MutatedEnemy.MutationType.ELECTRICITY, "suburbia_caverns"),
    "Retro Arcade": Region.new("Retro Arcade", ["retro_arcade_floor", "retro_arcade_mainframe"], "suburbia_completed", MutatedEnemy.MutationType.ELECTRICITY, "retro_arcade_mainframe"),
    "Neon City": Region.new("Neon City", ["neon_city_streets", "neon_city_skyline"], "retro_arcade_completed", MutatedEnemy.MutationType.FLAME, "neon_city_skyline"),
    "Bionic Zoo": Region.new("Bionic Zoo", ["bionic_zoo_prehistoric", "bionic_zoo_future"], "neon_city_completed", MutatedEnemy.MutationType.ACID, "bionic_zoo_future"),
    "Aqua Depths": Region.new("Aqua Depths", ["aqua_depths_coastal", "aqua_depths_deep_sea"], "bionic_zoo_completed", MutatedEnemy.MutationType.WATER, "aqua_depths_deep_sea"),
    "Cosmic Voyage": Region.new("Cosmic Voyage", ["cosmic_voyage_underwater", "cosmic_voyage_space_ship"], "aqua_depths_completed", MutatedEnemy.MutationType.FREEZE, "cosmic_voyage_space_ship"),
    "Orbital Laboratory": Region.new("Orbital Laboratory", ["orbital_lab_research", "orbital_lab_command"], "cosmic_voyage_completed", MutatedEnemy.MutationType.NONE, "orbital_lab_command")
}

var first_boss_rewards = {
    "gremland_village": "moon_water",
    "wild_wilds_jungle": ToolType.WHIP,
    "suburbia_streets": ToolType.SLINGSHOT,
    "retro_arcade_floor": ToolType.BOOMERANG,
    "neon_city_streets": ToolType.DRONE,
    "bionic_zoo_prehistoric": ToolType.GLIDER,
    "aqua_depths_coastal": WearableType.POWER_GLOVES,
    "cosmic_voyage_underwater": WearableType.BODYSUIT,
    "orbital_lab_research": "final_key_item"
}

var second_boss_rewards = {
    "gremland_outskirts": "wild_wilds_key",
    "wild_wilds_temples": "suburbia_key",
    "suburbia_caverns": "arcade_key",
    "retro_arcade_mainframe": "neon_city_key",
    "neon_city_skyline": "bionic_zoo_key",
    "bionic_zoo_future": "aqua_depths_key",
    "aqua_depths_deep_sea": "cosmic_voyage_key",
    "cosmic_voyage_space_ship": "orbital_lab_key"
}

@onready var tools_system = $ToolsSystem
@onready var item_system = $ItemSystem

var player: Node2D
var completed_levels: Array = []
var moon_water_unlocked: bool = false

# Debug variables
var debug_mode: bool = false

func initialize(player_node: Node2D):
    player = player_node

func load_level(level_name: String):
    for region in regions.values():
        if level_name in region.levels:
            current_region = region
            break
    
    if current_region:
        current_level = level_name
        var level_scene = load(f"res://scenes/levels/{level_name}.tscn")
        var level_instance = level_scene.instantiate()
        
        # Clear existing level if any
        for child in get_children():
            if child.is_in_group("level"):
                child.queue_free()
        
        add_child(level_instance)
        initialize_level(level_instance)
        emit_signal("level_loaded", level_name)
        if debug_mode:
            print(f"Loaded level: {level_name}")
    else:
        push_error("Error: Level not found in any region")

func initialize_level(level: Node):
    # Implementation remains the same
    pass

func complete_level(level_name: String):
    completed_levels.append(level_name)
    check_boss_rewards(level_name)
    award_health_bonus(level_name)
    emit_signal("level_completed", level_name)
    if debug_mode:
        print(f"Level completed: {level_name}")

func check_boss_rewards(level_name: String):
    if level_name in first_boss_rewards:
        var reward = first_boss_rewards[level_name]
        if reward == "moon_water":
            unlock_moon_water()
        elif reward == "final_key_item":
            award_key_item("final_boss_key")
        elif reward is ToolType:
            unlock_tool(reward)
        elif reward is WearableType:
            unlock_wearable(reward)
    elif level_name in second_boss_rewards:
        award_key_item(second_boss_rewards[level_name])

func unlock_moon_water():
    moon_water_unlocked = true
    emit_signal("moon_water_unlocked")
    if debug_mode:
        print("Moon Water container unlocked")

func unlock_tool(tool_type: ToolType):
    tools_system.unlock_tool(tool_type)
    emit_signal("tool_unlocked", tool_type)
    if debug_mode:
        print(f"Tool unlocked: {ToolType.keys()[tool_type]}")

func unlock_wearable(wearable_type: WearableType):
    item_system.unlock_wearable(wearable_type)
    emit_signal("wearable_unlocked", wearable_type)
    if debug_mode:
        print(f"Wearable unlocked: {WearableType.keys()[wearable_type]}")

func award_health_bonus(level_name: String):
    if level_name in first_boss_rewards or level_name in second_boss_rewards:
        item_system.add_health_bonus()
        emit_signal("health_bonus_awarded")
        if debug_mode:
            print("Health bonus awarded")

func award_key_item(item_name: String):
    item_system.add_key_item(item_name)
    emit_signal("key_item_awarded", item_name)
    if debug_mode:
        print(f"Key item awarded: {item_name}")

func get_next_level() -> String:
    return current_region.get_next_level(current_level)

func get_region_mutation(region_name: String) -> MutatedEnemy.MutationType:
    return regions[region_name].region_specific_mutation if region_name in regions else MutatedEnemy.MutationType.NONE

# Debug functions
func toggle_debug_mode():
    debug_mode = !debug_mode
    print("Level Manager debug mode: ", "ON" if debug_mode else "OFF")

func debug_print_level_info():
    print("Level Manager Info:")
    print(f"  Current Level: {current_level}")
    print(f"  Current Region: {current_region.name if current_region else 'None'}")
    print(f"  Completed Levels: {completed_levels}")
    print(f"  Moon Water Unlocked: {moon_water_unlocked}")

func debug_unlock_all_rewards():
    for reward in first_boss_rewards.values():
        if reward is ToolType:
            unlock_tool(reward)
        elif reward is WearableType:
            unlock_wearable(reward)
    unlock_moon_water()
    for key_item in second_boss_rewards.values():
        award_key_item(key_item)
    award_key_item("final_boss_key")
    print("All rewards unlocked")

# Add any additional level management methods here
