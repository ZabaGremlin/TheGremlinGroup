extends Node

signal mutation_changed(new_mutation)

enum MutationType { NONE, EXPLOSION, FLAME, ELECTRICITY, WATER, FREEZE, TOXIC, ACID }

var character: CharacterBody2D
var current_mutation: MutationType = MutationType.NONE
var mutation_duration: float = 30.0  # Duration of mutation in seconds
var mutation_timer: float = 0.0

# Debug variables
var debug_mode: bool = false
var infinite_mutation: bool = false

func initialize(_character: CharacterBody2D):
    character = _character

func _process(delta):
    if current_mutation != MutationType.NONE and not infinite_mutation:
        mutation_timer -= delta
        if mutation_timer <= 0:
            set_mutation(MutationType.NONE)

func set_mutation(mutation: MutationType):
    if current_mutation != mutation:
        remove_current_mutation_effects()
        current_mutation = mutation
        apply_mutation_effects()
        mutation_timer = mutation_duration
        emit_signal("mutation_changed", current_mutation)

func remove_current_mutation_effects():
    match current_mutation:
        MutationType.EXPLOSION:
            character.explosion_resistance = false
        MutationType.FLAME:
            character.fire_resistance = false
        MutationType.ELECTRICITY:
            character.shock_resistance = false
        MutationType.WATER:
            character.can_swim = false
        MutationType.FREEZE:
            character.cold_resistance = false
        MutationType.TOXIC:
            character.poison_resistance = false
        MutationType.ACID:
            character.acid_resistance = false

func apply_mutation_effects():
    match current_mutation:
        MutationType.EXPLOSION:
            character.explosion_resistance = true
        MutationType.FLAME:
            character.fire_resistance = true
        MutationType.ELECTRICITY:
            character.shock_resistance = true
        MutationType.WATER:
            character.can_swim = true
        MutationType.FREEZE:
            character.cold_resistance = true
        MutationType.TOXIC:
            character.poison_resistance = true
        MutationType.ACID:
            character.acid_resistance = true

func get_current_mutation() -> MutationType:
    return current_mutation

func get_mutation_time_left() -> float:
    return max(0, mutation_timer)

# Debug functions
func toggle_debug_mode():
    debug_mode = !debug_mode
    print("Mutation debug mode: ", "ON" if debug_mode else "OFF")

func toggle_infinite_mutation():
    infinite_mutation = !infinite_mutation
    print("Infinite mutation: ", "ON" if infinite_mutation else "OFF")

func debug_set_mutation(mutation_name: String):
    var mutation = MutationType.get(mutation_name.to_upper())
    if mutation != null:
        set_mutation(mutation)
        print(f"Mutation set to: {mutation_name}")
    else:
        print(f"Invalid mutation type: {mutation_name}")

func debug_print_mutation_info():
    print("Mutation Info:")
    print(f"  Current Mutation: {MutationType.keys()[current_mutation]}")
    print(f"  Time Left: {get_mutation_time_left():.2f} seconds")
    print("  Active Effects:")
    print(f"    Explosion Resistance: {character.explosion_resistance}")
    print(f"    Fire Resistance: {character.fire_resistance}")
    print(f"    Shock Resistance: {character.shock_resistance}")
    print(f"    Can Swim: {character.can_swim}")
    print(f"    Cold Resistance: {character.cold_resistance}")
    print(f"    Poison Resistance: {character.poison_resistance}")
    print(f"    Acid Resistance: {character.acid_resistance}")

func debug_cycle_mutation():
    var next_mutation = (current_mutation + 1) % MutationType.size()
    set_mutation(next_mutation)
    print("Debug: Mutation changed to ", MutationType.keys()[next_mutation])

# Add any additional mutation-related methods here
