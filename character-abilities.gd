extends Node

enum GremlinType { GREMLI, GREMANI, GREY, GRETCHEN }

signal ability_used(ability_name)
signal ability_cooldown_changed(ability_name, current_cooldown)

var character: CharacterBody2D
var gremlin_type: GremlinType

var abilities = {
    "controlled_transformation": {
        "cooldown": 30.0,
        "current_cooldown": 0.0
    },
    "enhanced_mutation": {
        "cooldown": 30.0,
        "current_cooldown": 0.0
    },
    "sneaky": {
        "cooldown": 30.0,
        "current_cooldown": 0.0
    },
    "medic": {
        "cooldown": 30.0,
        "current_cooldown": 0.0
    }
}

# Debug flags
var debug_mode: bool = false
var no_cooldown: bool = false

func initialize(_character: CharacterBody2D, _gremlin_type: GremlinType):
    character = _character
    gremlin_type = _gremlin_type

func _process(delta):
    update_cooldowns(delta)

func use_ability() -> bool:
    var ability_name = get_ability_name()
    if ability_name == "":
        print("No specific ability for this character type")
        return false

    var ability = abilities[ability_name]
    
    if not debug_mode or not no_cooldown:
        if ability.current_cooldown > 0:
            print("Ability on cooldown: ", ability_name)
            return false
    
    # Use the ability
    match ability_name:
        "controlled_transformation":
            controlled_transformation()
        "enhanced_mutation":
            enhanced_mutation()
        "sneaky":
            sneaky()
        "medic":
            medic()
    
    if not debug_mode or not no_cooldown:
        ability.current_cooldown = ability.cooldown
    emit_signal("ability_used", ability_name)
    return true

func update_cooldowns(delta):
    for ability_name in abilities:
        var ability = abilities[ability_name]
        if ability.current_cooldown > 0:
            ability.current_cooldown = max(0, ability.current_cooldown - delta)
            emit_signal("ability_cooldown_changed", ability_name, ability.current_cooldown)

func get_ability_name() -> String:
    match gremlin_type:
        GremlinType.GREMLI:
            return "controlled_transformation"
        GremlinType.GREMANI:
            return "enhanced_mutation"
        GremlinType.GREY:
            return "sneaky"
        GremlinType.GRETCHEN:
            return "medic"
    return ""

func controlled_transformation():
    print("Gremli uses Controlled Transformation!")
    character.toggle_transformation()

func enhanced_mutation():
    print("Gremani uses Enhanced Mutation!")
    character.enhance_current_mutation()

func sneaky():
    print("Grey uses Sneaky!")
    character.become_sneaky()

func medic():
    print("Gretchen uses Medic!")
    character.heal_nearby_allies()

# Debug functions
func toggle_debug_mode():
    debug_mode = !debug_mode
    print("Character Abilities debug mode: ", "ON" if debug_mode else "OFF")

func toggle_no_cooldown():
    no_cooldown = !no_cooldown
    print("No cooldown: ", "ON" if no_cooldown else "OFF")

func debug_print_ability_info():
    print(f"Character Type: {GremlinType.keys()[gremlin_type]}")
    var ability_name = get_ability_name()
    if ability_name != "":
        var ability = abilities[ability_name]
        print(f"Ability: {ability_name}")
        print(f"  Cooldown: {ability.cooldown}")
        print(f"  Current Cooldown: {ability.current_cooldown}")
    else:
        print("No specific ability for this character type")

func debug_use_ability():
    print(f"Using ability for {GremlinType.keys()[gremlin_type]}")
    use_ability()

func debug_reset_cooldown():
    var ability_name = get_ability_name()
    if ability_name != "":
        abilities[ability_name].current_cooldown = 0
        print(f"Reset cooldown for {ability_name}")
    else:
        print("No specific ability to reset cooldown")

func debug_set_cooldown(cooldown: float):
    var ability_name = get_ability_name()
    if ability_name != "":
        abilities[ability_name].cooldown = cooldown
        print(f"Set cooldown for {ability_name} to {cooldown} seconds")
    else:
        print("No specific ability to set cooldown")

# Add any additional character-specific ability methods here
