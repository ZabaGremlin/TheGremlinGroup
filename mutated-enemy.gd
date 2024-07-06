extends BaseEnemy

class_name MutatedEnemy

enum MutationType { EXPLOSION, FLAME, ELECTRICITY, WATER, FREEZE, TOXIC, ACID }

@export var mutation_type: MutationType
@export var is_strong: bool = false

# Debug variables
var debug_mode: bool = false

func _ready():
    super._ready()
    if is_strong:
        max_health *= 2
        health = max_health
        attack_power *= 1.5
    apply_mutation_effects()

func attack():
    super.attack()
    apply_mutation_effect()

func apply_mutation_effect():
    match mutation_type:
        MutationType.EXPLOSION:
            create_explosion()
        MutationType.FLAME:
            create_flame_trail()
        MutationType.ELECTRICITY:
            create_electric_field()
        MutationType.WATER:
            create_water_splash()
        MutationType.FREEZE:
            create_freeze_zone()
        MutationType.TOXIC:
            create_toxic_cloud()
        MutationType.ACID:
            create_acid_pool()

func create_explosion():
    print("Explosion effect applied")
    # Implement explosion effect

func create_flame_trail():
    print("Flame trail effect applied")
    # Implement flame trail effect

func create_electric_field():
    print("Electric field effect applied")
    # Implement electric field effect

func create_water_splash():
    print("Water splash effect applied")
    # Implement water splash effect

func create_freeze_zone():
    print("Freeze zone effect applied")
    # Implement freeze zone effect

func create_toxic_cloud():
    print("Toxic cloud effect applied")
    # Implement toxic cloud effect

func create_acid_pool():
    print("Acid pool effect applied")
    # Implement acid pool effect

func take_damage(amount: float):
    if is_strong and player.mutation_system.get_current_mutation() == mutation_type:
        amount *= 0.75  # 25% damage reduction
    super.take_damage(amount)

func die():
    # Chance to drop mutation power-up
    if randf() < 0.5:  # 50% chance
        drop_mutation_power_up()
    super.die()

func drop_mutation_power_up():
    # Implement logic to spawn a mutation power-up
    print(f"Dropped {MutationType.keys()[mutation_type]} power-up")

func apply_mutation_effects():
    # Apply permanent effects based on mutation type
    match mutation_type:
        MutationType.EXPLOSION:
            attack_power *= 1.2
        MutationType.FLAME:
            move_speed *= 1.1
        MutationType.ELECTRICITY:
            attack_speed *= 1.2
        MutationType.WATER:
            max_health *= 1.2
            health = max_health
        MutationType.FREEZE:
            defense *= 1.2
        MutationType.TOXIC:
            poison_resistance = true
        MutationType.ACID:
            acid_trail = true

# Debug functions
func toggle_debug_mode():
    debug_mode = !debug_mode
    print("Mutated Enemy debug mode: ", "ON" if debug_mode else "OFF")

func debug_print_info():
    print("Mutated Enemy Info:")
    print(f"  Mutation Type: {MutationType.keys()[mutation_type]}")
    print(f"  Is Strong: {is_strong}")
    print(f"  Health: {health}/{max_health}")
    print(f"  Attack Power: {attack_power}")
    print(f"  Move Speed: {move_speed}")

func debug_set_mutation(mutation: String):
    var new_mutation = MutationType.get(mutation.to_upper())
    if new_mutation != null:
        mutation_type = new_mutation
        apply_mutation_effects()
        print(f"Mutation set to: {mutation}")
    else:
        print(f"Invalid mutation type: {mutation}")

func debug_toggle_strong():
    is_strong = !is_strong
    if is_strong:
        max_health *= 2
        health = max_health
        attack_power *= 1.5
    else:
        max_health /= 2
        health = min(health, max_health)
        attack_power /= 1.5
    print(f"Strong mode: {'ON' if is_strong else 'OFF'}")

func debug_force_mutation_effect():
    apply_mutation_effect()
    print("Forced mutation effect")

# Add any additional mutated enemy-related methods here
