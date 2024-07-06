extends Node

enum ToolType { WHIP, SLINGSHOT, BOOMERANG, DRONE, GLIDER }
enum MutationType { NONE, EXPLOSION, FLAME, ELECTRICITY, WATER, FREEZE, TOXIC, ACID }

# Debug flags
var debug_mode: bool = false
var infinite_ammo: bool = false
var no_cooldown: bool = false

class Tool:
    var name: String
    var tool_type: ToolType
    var description: String
    var base_damage: float
    var cooldown: float
    var current_cooldown: float
    var ammo: int
    var max_ammo: int
    var is_unlocked: bool = false
    var is_upgraded: bool = false
    var upgrade_data: Dictionary = {}

    func _init(_name: String, _tool_type: ToolType, _description: String, _base_damage: float, _cooldown: float, _max_ammo: int):
        name = _name
        tool_type = _tool_type
        description = _description
        base_damage = _base_damage
        cooldown = _cooldown
        current_cooldown = 0
        max_ammo = _max_ammo
        ammo = max_ammo

    func use(player: Node2D, aim_direction: Vector2) -> Node2D:
        if current_cooldown > 0 or ammo <= 0:
            return null
        current_cooldown = cooldown
        ammo -= 1
        return _perform_action(player, aim_direction)

    func _perform_action(player: Node2D, aim_direction: Vector2) -> Node2D:
        # This method should be overridden by specific tool classes
        return null

    func update(delta: float):
        if current_cooldown > 0:
            current_cooldown -= delta

    func upgrade():
        is_upgraded = true
        # Apply upgrade effects (to be implemented in the future)
        for key in upgrade_data:
            set(key, upgrade_data[key])

    # Debug method
    func debug_info() -> String:
        return "Tool: %s, Damage: %.2f, Cooldown: %.2f, Ammo: %d/%d, Unlocked: %s, Upgraded: %s" % [name, base_damage, cooldown, ammo, max_ammo, is_unlocked, is_upgraded]

class Whip extends Tool:
    func _init():
        super._init("Whip", ToolType.WHIP, "A versatile tool for swinging and grappling", 10, 0.5, -1)  # -1 for infinite uses

    func _perform_action(player: Node2D, aim_direction: Vector2) -> Node2D:
        var whip = preload("res://scenes/Whip.tscn").instantiate()
        whip.initialize(player.global_position, aim_direction, base_damage)
        player.add_child(whip)
        return whip

class Slingshot extends Tool:
    func _init():
        super._init("Slingshot", ToolType.SLINGSHOT, "Shoot projectiles at enemies and targets", 8, 0.7, 20)

    func _perform_action(player: Node2D, aim_direction: Vector2) -> Node2D:
        var projectile = preload("res://scenes/SlingshotProjectile.tscn").instantiate()
        projectile.initialize(player.global_position, aim_direction, base_damage)
        player.get_parent().add_child(projectile)
        return projectile

class Boomerang extends Tool:
    func _init():
        super._init("Boomerang", ToolType.BOOMERANG, "A returning projectile that can hit multiple targets", 12, 1.0, 1)

    func _perform_action(player: Node2D, aim_direction: Vector2) -> Node2D:
        var boomerang = preload("res://scenes/Boomerang.tscn").instantiate()
        boomerang.initialize(player.global_position, aim_direction, base_damage, player)
        player.get_parent().add_child(boomerang)
        return boomerang

class Drone extends Tool:
    var detection_range: float = 100

    func _init():
        super._init("Drone", ToolType.DRONE, "A flying device for scouting and activating remote switches", 5, 5.0, 1)

    func _perform_action(player: Node2D, aim_direction: Vector2) -> Node2D:
        var drone = preload("res://scenes/Drone.tscn").instantiate()
        drone.initialize(player.global_position, detection_range)
        player.get_parent().add_child(drone)
        return drone

class Glider extends Tool:
    var is_gliding: bool = false
    var mutation_conversions: Dictionary = {
        MutationType.EXPLOSION: false,
        MutationType.FLAME: false,
        MutationType.ELECTRICITY: false,
        MutationType.WATER: false,
        MutationType.FREEZE: false,
        MutationType.TOXIC: false,
        MutationType.ACID: false
    }

    func _init():
        super._init("Glider", ToolType.GLIDER, "Glide through the air and reach distant platforms", 0, 1.0, -1)  # -1 for infinite uses
        upgrade_data = {
            "explosion_conversion": false,
            "flame_conversion": false,
            "electricity_conversion": false,
            "water_conversion": false,
            "freeze_conversion": false,
            "toxic_conversion": false,
            "acid_conversion": false
        }

    func _perform_action(player: Node2D, aim_direction: Vector2) -> Node2D:
        is_gliding = !is_gliding
        if is_gliding:
            player.start_gliding()
        else:
            player.stop_gliding()
        return null

    func upgrade():
        super.upgrade()
        # Apply upgrade effects for mutation conversions
        mutation_conversions[MutationType.EXPLOSION] = upgrade_data["explosion_conversion"]
        mutation_conversions[MutationType.FLAME] = upgrade_data["flame_conversion"]
        mutation_conversions[MutationType.ELECTRICITY] = upgrade_data["electricity_conversion"]
        mutation_conversions[MutationType.WATER] = upgrade_data["water_conversion"]
        mutation_conversions[MutationType.FREEZE] = upgrade_data["freeze_conversion"]
        mutation_conversions[MutationType.TOXIC] = upgrade_data["toxic_conversion"]
        mutation_conversions[MutationType.ACID] = upgrade_data["acid_conversion"]

    func can_convert(mutation: MutationType) -> bool:
        return is_upgraded and mutation_conversions[mutation]

    func convert(mutation: MutationType, player: Node2D) -> void:
        if can_convert(mutation):
            match mutation:
                MutationType.EXPLOSION:
                    _convert_to_rocket(player)
                MutationType.FLAME:
                    _convert_to_meteorite(player)
                MutationType.ELECTRICITY:
                    _convert_to_sky_lift(player)
                MutationType.WATER:
                    _convert_to_mini_sub(player)
                MutationType.FREEZE:
                    _convert_to_sled(player)
                MutationType.TOXIC:
                    _convert_to_sterile_bubble(player)
                MutationType.ACID:
                    _convert_to_plastic_barrel(player)

    func _convert_to_rocket(player: Node2D):
        # Implement rocket conversion logic
        pass

    func _convert_to_meteorite(player: Node2D):
        # Implement meteorite conversion logic
        pass

    func _convert_to_sky_lift(player: Node2D):
        # Implement sky lift conversion logic
        pass

    func _convert_to_mini_sub(player: Node2D):
        # Implement mini sub conversion logic
        pass

    func _convert_to_sled(player: Node2D):
        # Implement sled conversion logic
        pass

    func _convert_to_sterile_bubble(player: Node2D):
        # Implement sterile bubble conversion logic
        pass

    func _convert_to_plastic_barrel(player: Node2D):
        # Implement plastic barrel conversion logic
        pass

    # Override debug_info to include mutation conversion information
    func debug_info() -> String:
        var base_info = super.debug_info()
        var conversion_info = "Mutation Conversions: "
        for mutation in mutation_conversions:
            conversion_info += f"{MutationType.keys()[mutation]}: {mutation_conversions[mutation]}, "
        return base_info + "\n" + conversion_info.trim_suffix(", ")

var tools = {
    ToolType.WHIP: Whip.new(),
    ToolType.SLINGSHOT: Slingshot.new(),
    ToolType.BOOMERANG: Boomerang.new(),
    ToolType.DRONE: Drone.new(),
    ToolType.GLIDER: Glider.new()
}

func get_tool(tool_type: ToolType) -> Tool:
    return tools[tool_type]

func unlock_tool(tool_type: ToolType):
    if tool_type in tools:
        tools[tool_type].is_unlocked = true
        if debug_mode:
            print(f"Tool unlocked: {tools[tool_type].name}")

func is_tool_unlocked(tool_type: ToolType) -> bool:
    return tool_type in tools and tools[tool_type].is_unlocked

func use_tool(tool_type: ToolType, player: Node2D, aim_direction: Vector2, current_mutation: MutationType = MutationType.NONE):
    var tool = get_tool(tool_type)
    if tool.is_unlocked and (tool.ammo > 0 or infinite_ammo) and (tool.current_cooldown <= 0 or no_cooldown):
        if tool_type == ToolType.GLIDER and tool.is_upgraded:
            var glider = tool as Glider
            if glider.can_convert(current_mutation):
                glider.convert(current_mutation, player)
                return null
        return tool.use(player, aim_direction)
    return null

func update_tools(delta: float):
    for tool in tools.values():
        tool.update(delta)

# Debug functions
func toggle_debug_mode():
    debug_mode = !debug_mode
    print("Tools System debug mode: ", "ON" if debug_mode else "OFF")

func toggle_infinite_ammo():
    infinite_ammo = !infinite_ammo
    print("Infinite ammo: ", "ON" if infinite_ammo else "OFF")

func toggle_no_cooldown():
    no_cooldown = !no_cooldown
    print("No cooldown: ", "ON" if no_cooldown else "OFF")

func debug_print_tool_info():
    print("Tools Information:")
    for tool in tools.values():
        print(tool.debug_info())

func debug_unlock_all_tools():
    for tool in tools.values():
        tool.is_unlocked = true
    print("All tools unlocked")

func debug_upgrade_all_tools():
    for tool in tools.values():
        tool.upgrade()
    print("All tools upgraded")

func debug_reset_all_tools():
    for tool in tools.values():
        tool.is_unlocked = false
        tool.is_upgraded = false
        tool.ammo = tool.max_ammo
        tool.current_cooldown = 0
    print("All tools reset")

# Add any additional tool-related methods here
