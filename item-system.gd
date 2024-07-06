extends Node

enum ItemType { TOOL, HEALING, MUTATION, QUEST }
enum ToolType { SLINGSHOT, BOOMERANG, WHIP, GLIDER, DRONE }
enum MutationType { NONE, EXPLOSION, FLAME, ELECTRICITY, WATER, FREEZE, TOXIC, ACID }
enum RegionType { 
    GREMLAND, 
    WILD_WILDS, 
    SUBURBIA_NIGHTS, 
    RETRO_ARCADE, 
    NEON_CITY, 
    BIONIC_ZOO, 
    AQUA_DEPTHS, 
    COSMIC_VOYAGE, 
    ORBITAL_LABORATORY 
}

enum ToolAcquisitionRegion {
    WILD_WILDS,
    SUBURBIA_NIGHTS,
    RETRO_ARCADE,
    NEON_CITY,
    BIONIC_ZOO,
    ORBITAL_LABORATORY
}

# Dictionary to store tool acquisition information
var tool_acquisition_info = {
    ToolType.WHIP: {
        "region": ToolAcquisitionRegion.WILD_WILDS,
        "boss_level": "wild_wilds_jungle",
        "upgrade_level": "wild_wilds_temples"
    },
    ToolType.SLINGSHOT: {
        "region": ToolAcquisitionRegion.SUBURBIA_NIGHTS,
        "boss_level": "suburbia_streets",
        "upgrade_level": "suburbia_caverns"
    },
    ToolType.BOOMERANG: {
        "region": ToolAcquisitionRegion.RETRO_ARCADE,
        "boss_level": "retro_arcade_floor",
        "upgrade_level": "retro_arcade_mainframe"
    },
    ToolType.DRONE: {
        "region": ToolAcquisitionRegion.NEON_CITY,
        "boss_level": "neon_city_streets",
        "upgrade_level": "orbital_lab_research"  # Special case for Drone upgrade
    },
    ToolType.GLIDER: {
        "region": ToolAcquisitionRegion.BIONIC_ZOO,
        "boss_level": "bionic_zoo_prehistoric",
        "upgrade_level": "bionic_zoo_future"
    }
}

# Debug variables
var debug_mode: bool = false
var infinite_items: bool = false
var no_cooldown: bool = false

class Item:
    var name: String
    var type: ItemType
    var description: String
    var quantity: int
    var max_stack: int
    var healing_percentage: float
    var mutation_type: int  # -1 for non-mutation items
    var skin: String  # Acts as a unique identifier
    var use_animation: String
    var region_affinity: RegionType

    func _init(_name: String, _type: ItemType, _description: String, _max_stack: int = 1, _healing_percentage: float = 0, _mutation_type: int = -1, _skin: String = "default", _use_animation: String = "default_use", _region_affinity: RegionType = RegionType.GREMLAND):
        name = _name
        type = _type
        description = _description
        quantity = 1
        max_stack = _max_stack
        healing_percentage = _healing_percentage
        mutation_type = _mutation_type
        skin = _skin
        use_animation = _use_animation
        region_affinity = _region_affinity

    func use(player):
        if type == ItemType.HEALING or type == ItemType.MUTATION:
            player.heal(player.max_health * healing_percentage)
        if type == ItemType.MUTATION:
            player.mutation_system.set_mutation(mutation_type)
        player.animation_player.play(use_animation)
        quantity -= 1

    func get_unique_id():
        return f"{name}_{skin}"

class Tool:
    var name: String
    var tool_type: ToolType
    var base_damage: float
    var cooldown: float
    var last_use_time: float
    var animation_name: String
    var is_upgraded: bool = false

    func _init(_name: String, _tool_type: ToolType, _base_damage: float, _cooldown: float, _animation_name: String):
        name = _name
        tool_type = _tool_type
        base_damage = _base_damage
        cooldown = _cooldown
        animation_name = _animation_name
        last_use_time = 0

    func can_use() -> bool:
        return Time.get_ticks_msec() - last_use_time > cooldown * 1000

    func use():
        last_use_time = Time.get_ticks_msec()

    func upgrade():
        is_upgraded = true
        base_damage *= 1.5  # 50% damage increase
        cooldown *= 0.75  # 25% cooldown reduction

func create_item(name: String, type: ItemType, description: String, max_stack: int = 1, healing_percentage: float = 0, mutation_type: int = -1, skin: String = "default", use_animation: String = "default_use", region_affinity: RegionType = RegionType.GREMLAND) -> Item:
    return Item.new(name, type, description, max_stack, healing_percentage, mutation_type, skin, use_animation, region_affinity)

func create_tool(name: String, tool_type: ToolType, base_damage: float, cooldown: float, animation_name: String) -> Tool:
    return Tool.new(name, tool_type, base_damage, cooldown, animation_name)

func create_predefined_item(item_name: String) -> Item:
    match item_name:
        "Minor Healing":
            return create_item("Minor Healing", ItemType.HEALING, "Restores 30% of max health", 99, 0.3)
        "Major Healing":
            return create_item("Major Healing", ItemType.HEALING, "Restores 60% of max health", 99, 0.6)
        "Explosion Berry":
            return create_item("Explosion Berry", ItemType.MUTATION, "Applies Explosion mutation and restores 10% of max health", 99, 0.1, MutationType.EXPLOSION, "default", "use_explosion_berry", RegionType.GREMLAND)
        "Flame Chili":
            return create_item("Flame Chili", ItemType.MUTATION, "Applies Flame mutation and restores 10% of max health", 99, 0.1, MutationType.FLAME, "default", "use_flame_chili", RegionType.NEON_CITY)
        "Electric Lemon":
            return create_item("Electric Lemon", ItemType.MUTATION, "Applies Electricity mutation and restores 10% of max health", 99, 0.1, MutationType.ELECTRICITY, "default", "use_electric_lemon", RegionType.SUBURBIA_NIGHTS)
        "Water Melon":
            return create_item("Water Melon", ItemType.MUTATION, "Applies Water mutation and restores 10% of max health", 99, 0.1, MutationType.WATER, "default", "use_water_melon", RegionType.AQUA_DEPTHS)
        "Frost Plum":
            return create_item("Frost Plum", ItemType.MUTATION, "Applies Freeze mutation and restores 10% of max health", 99, 0.1, MutationType.FREEZE, "default", "use_frost_plum", RegionType.COSMIC_VOYAGE)
        "Toxic Broccoli":
            return create_item("Toxic Broccoli", ItemType.MUTATION, "Applies Toxic mutation and restores 10% of max health", 99, 0.1, MutationType.TOXIC, "default", "use_toxic_broccoli", RegionType.WILD_WILDS)
        "Acidic Orange":
            return create_item("Acidic Orange", ItemType.MUTATION, "Applies Acid mutation and restores 10% of max health", 99, 0.1, MutationType.ACID, "default", "use_acidic_orange", RegionType.BIONIC_ZOO)
        "Fruit Basket":
            return create_item("Fruit Basket", ItemType.MUTATION, "Applies a random mutation and restores 10% of max health", 99, 0.1, -1, "default", "use_fruit_basket", RegionType.ORBITAL_LABORATORY)
        _:
            push_error("Undefined item: " + item_name)
            return null

func get_all_mutation_items() -> Array:
    return [
        create_predefined_item("Explosion Berry"),
        create_predefined_item("Flame Chili"),
        create_predefined_item("Electric Lemon"),
        create_predefined_item("Water Melon"),
        create_predefined_item("Frost Plum"),
        create_predefined_item("Toxic Broccoli"),
        create_predefined_item("Acidic Orange")
    ]

func get_random_mutation_item() -> Item:
    var mutation_items = get_all_mutation_items()
    return mutation_items[randi() % mutation_items.size()]

func use_fruit_basket(player):
    var random_item = get_random_mutation_item()
    player.heal(player.max_health * 0.1)
    player.mutation_system.set_mutation(random_item.mutation_type)
    player.animation_player.play("use_fruit_basket")

func get_items_by_region(region: RegionType) -> Array:
    var region_items = []
    for item in get_all_mutation_items():
        if item.region_affinity == region or item.region_affinity == RegionType.ORBITAL_LABORATORY:
            region_items.append(item)
    return region_items

func apply_tool_effect(tool: Tool, player, current_mutation):
    match tool.tool_type:
        ToolType.SLINGSHOT:
            # Implement slingshot logic
            pass
        ToolType.BOOMERANG:
            # Implement boomerang logic
            pass
        ToolType.WHIP:
            # Implement whip logic
            pass
        ToolType.GLIDER:
            # Implement glider logic
            pass
        ToolType.DRONE:
            # Implement drone logic
            pass

func is_tool_unlocked(tool_type: ToolType, completed_levels: Array) -> bool:
    var info = tool_acquisition_info[tool_type]
    return info["boss_level"] in completed_levels

func is_tool_upgrade_available(tool_type: ToolType, completed_levels: Array, drone_upgraded: bool) -> bool:
    var info = tool_acquisition_info[tool_type]
    return info["upgrade_level"] in completed_levels and (tool_type == ToolType.DRONE or drone_upgraded)

func get_tool_upgrade_level(tool_type: ToolType) -> String:
    return tool_acquisition_info[tool_type]["upgrade_level"]

# Debug functions
func toggle_debug_mode():
    debug_mode = !debug_mode
    print("Item System debug mode: ", "ON" if debug_mode else "OFF")

func toggle_infinite_items():
    infinite_items = !infinite_items
    print("Infinite items: ", "ON" if infinite_items else "OFF")

func toggle_no_cooldown():
    no_cooldown = !no_cooldown
    print("No cooldown: ", "ON" if no_cooldown else "OFF")

func debug_create_all_items():
    var all_items = []
    for item_name in ["Minor Healing", "Major Healing", "Explosion Berry", "Flame Chili", "Electric Lemon", "Water Melon", "Frost Plum", "Toxic Broccoli", "Acidic Orange", "Fruit Basket"]:
        all_items.append(create_predefined_item(item_name))
    return all_items

func debug_create_all_tools():
    var all_tools = []
    all_tools.append(create_tool("Slingshot", ToolType.SLINGSHOT, 10, 0.5, "use_slingshot"))
    all_tools.append(create_tool("Boomerang", ToolType.BOOMERANG, 15, 1.0, "use_boomerang"))
    all_tools.append(create_tool("Whip", ToolType.WHIP, 12, 0.7, "use_whip"))
    all_tools.append(create_tool("Glider", ToolType.GLIDER, 5, 0.5, "use_glider"))
    all_tools.append(create_tool("Drone", ToolType.DRONE, 0, 10.0, "use_drone"))
    return all_tools

func debug_print_item_info(item: Item):
    print("Item Info:")
    print(f"  Name: {item.name}")
    print(f"  Type: {ItemType.keys()[item.type]}")
    print(f"  Description: {item.description}")
    print(f"  Max Stack: {item.max_stack}")
    print(f"  Healing %: {item.healing_percentage}")
    print(f"  Mutation Type: {MutationType.keys()[item.mutation_type] if item.mutation_type != -1 else 'None'}")
    print(f"  Region Affinity: {RegionType.keys()[item.region_affinity]}")

func debug_print_tool_info(tool: Tool):
    print("Tool Info:")
    print(f"  Name: {tool.name}")
    print(f"  Type: {ToolType.keys()[tool.tool_type]}")
    print(f"  Base Damage: {tool.base_damage}")
    print(f"  Cooldown: {tool.cooldown}")
    print(f"  Is Upgraded: {tool.is_upgraded}")

func debug_use_item(item: Item, player):
    print(f"Using item: {item.name}")
    item.use(player)
    print(f"Item used. Quantity left: {item.quantity}")

func debug_use_tool(tool: Tool, player):
    if tool.can_use() or no_cooldown:
        print(f"Using tool: {tool.name}")
        tool.use()
        apply_tool_effect(tool, player, player.mutation_system.get_current_mutation())
    else:
        print(f"Tool {tool.name} is on cooldown")

# Add any additional item-related methods here
