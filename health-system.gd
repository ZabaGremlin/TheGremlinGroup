extends Node

signal health_changed(new_health, max_health)
signal died

var character: CharacterBody2D
var max_health: float
var current_health: float

# Resistance properties
var physical_resistance: float = 0.0
var elemental_resistance: float = 0.0

# Regeneration properties
var regen_rate: float = 0.0
var regen_interval: float = 1.0
var regen_timer: float = 0.0

# Debug variables
var debug_mode: bool = false
var invincible: bool = false

func initialize(_character: CharacterBody2D, _max_health: float):
    character = _character
    max_health = _max_health
    current_health = max_health

func _process(delta):
    if regen_rate > 0:
        regen_timer += delta
        if regen_timer >= regen_interval:
            regen_timer = 0
            heal(regen_rate)

func take_damage(amount: float, damage_type: String = "physical"):
    if invincible:
        print("Character is invincible, no damage taken")
        return

    var actual_damage = calculate_damage(amount, damage_type)
    current_health = max(0, current_health - actual_damage)
    emit_signal("health_changed", current_health, max_health)
    
    if current_health == 0:
        emit_signal("died")
    
    if debug_mode:
        print(f"Took {actual_damage} damage. Current health: {current_health}/{max_health}")

func heal(amount: float):
    var old_health = current_health
    current_health = min(max_health, current_health + amount)
    emit_signal("health_changed", current_health, max_health)
    
    if debug_mode:
        print(f"Healed for {current_health - old_health}. Current health: {current_health}/{max_health}")

func calculate_damage(amount: float, damage_type: String) -> float:
    var resistance = physical_resistance if damage_type == "physical" else elemental_resistance
    var actual_damage = amount * (1 - resistance)
    return actual_damage

func get_health_percentage() -> float:
    return current_health / max_health

func set_max_health(new_max_health: float):
    var health_percentage = get_health_percentage()
    max_health = new_max_health
    current_health = max_health * health_percentage
    emit_signal("health_changed", current_health, max_health)

func set_resistances(physical: float, elemental: float):
    physical_resistance = clamp(physical, 0, 1)
    elemental_resistance = clamp(elemental, 0, 1)

func set_regen(rate: float, interval: float = 1.0):
    regen_rate = rate
    regen_interval = interval

# Debug functions
func toggle_debug_mode():
    debug_mode = !debug_mode
    print("Health System debug mode: ", "ON" if debug_mode else "OFF")

func toggle_invincibility():
    invincible = !invincible
    print("Invincibility: ", "ON" if invincible else "OFF")

func debug_print_info():
    print("Health System Info:")
    print(f"  Current Health: {current_health}/{max_health}")
    print(f"  Health Percentage: {get_health_percentage() * 100}%")
    print(f"  Physical Resistance: {physical_resistance * 100}%")
    print(f"  Elemental Resistance: {elemental_resistance * 100}%")
    print(f"  Regen Rate: {regen_rate} per {regen_interval} seconds")

func debug_set_health(health: float):
    current_health = clamp(health, 0, max_health)
    emit_signal("health_changed", current_health, max_health)
    print(f"Set current health to: {current_health}")

func debug_apply_damage(amount: float, damage_type: String = "physical"):
    print(f"Applying {amount} {damage_type} damage")
    take_damage(amount, damage_type)

func debug_full_heal():
    heal(max_health)
    print("Fully healed character")

# Add any additional health-related methods here
