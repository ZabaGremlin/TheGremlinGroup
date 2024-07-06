extends Node

signal water_changed(new_water, max_water)
signal ability_used(ability_name)
signal transformation_state_changed(is_transformed)

var character: CharacterBody2D
var max_water: float = 100.0
var current_water: float = max_water
var is_transformed: bool = false
var game_time: int = 0  # in minutes, 0 = 12:00 AM

var abilities = {
    "spawn": {
        "water_cost": 25.0,
        "cooldown": 10.0,
        "current_cooldown": 0.0
    },
    "transform": {
        "cooldown": 0.0,
        "current_cooldown": 0.0
    },
    "absorb_mutation": {
        "cooldown": 1.0,
        "current_cooldown": 0.0
    }
}

# Debug flags
var debug_mode: bool = false
var infinite_water: bool = false
var no_cooldown: bool = false

func initialize(_character: CharacterBody2D):
    character = _character

func _process(delta):
    update_cooldowns(delta)
    update_game_time(delta)

func use_ability(ability_name: String) -> bool:
    if not abilities.has(ability_name):
        print("Ability not found: ", ability_name)
        return false
    
    var ability = abilities[ability_name]
    
    if not debug_mode or not no_cooldown:
        if ability.current_cooldown > 0:
            print("Ability on cooldown: ", ability_name)
            return false
    
    if ability.has("water_cost") and current_water < ability.water_cost and not infinite_water:
        print("Not enough water for ability: ", ability_name)
        return false
    
    # Use the ability
    match ability_name:
        "spawn":
            spawn_gremlin()
        "transform":
            transform()
        "absorb_mutation":
            absorb_mutation()
    
    if ability.has("water_cost") and not infinite_water:
        use_water(ability.water_cost)
    if not debug_mode or not no_cooldown:
        ability.current_cooldown = ability.cooldown
    emit_signal("ability_used", ability_name)
    return true

func update_cooldowns(delta):
    for ability in abilities.values():
        if ability.current_cooldown > 0:
            ability.current_cooldown = max(0, ability.current_cooldown - delta)

func use_water(amount: float):
    current_water = max(0, current_water - amount)
    emit_signal("water_changed", current_water, max_water)

func add_water(amount: float):
    current_water = min(max_water, current_water + amount)
    emit_signal("water_changed", current_water, max_water)

func spawn_gremlin():
    var gremlin_scene = load("res://scenes/Gremlin.tscn")
    var gremlin = gremlin_scene.instantiate()
    gremlin.global_position = character.global_position + Vector2(0, -50)  # Spawn above the character
    character.get_parent().add_child(gremlin)
    print("Gremlin spawned!")

func transform():
    if is_transformation_time():
        is_transformed = true
        emit_signal("transformation_state_changed", is_transformed)
        # Implement transformation effects

func absorb_mutation():
    # Implement mutation absorption logic
    pass

func is_transformation_time() -> bool:
    var hours = game_time / 60
    return hours >= 0 and hours < 6

func update_game_time(delta):
    game_time = (game_time + int(delta * 60)) % 1440  # 1440 minutes in a day

func consume_food():
    if is_transformation_time():
        transform()

# Debug functions
func toggle_debug_mode():
    debug_mode = !debug_mode
    print("Debug mode: ", "ON" if debug_mode else "OFF")

func toggle_infinite_water():
    infinite_water = !infinite_water
    print("Infinite water: ", "ON" if infinite_water else "OFF")

func toggle_no_cooldown():
    no_cooldown = !no_cooldown
    print("No cooldown: ", "ON" if no_cooldown else "OFF")

func debug_print_ability_info():
    for ability_name in abilities.keys():
        var ability = abilities[ability_name]
        print(f"Ability: {ability_name}")
        print(f"  Cooldown: {ability.cooldown}")
        print(f"  Current Cooldown: {ability.current_cooldown}")
        if ability.has("water_cost"):
            print(f"  Water Cost: {ability.water_cost}")
        print("---")

func debug_use_all_abilities():
    for ability_name in abilities.keys():
        print(f"Using ability: {ability_name}")
        use_ability(ability_name)
        print("---")

func debug_set_game_time(hours: int, minutes: int):
    game_time = (hours * 60 + minutes) % 1440
    print(f"Game time set to {hours:02d}:{minutes:02d}")

func debug_print_game_time():
    var hours = game_time / 60
    var minutes = game_time % 60
    print(f"Current game time: {hours:02d}:{minutes:02d}")

# Add any additional ability-related methods here
