extends BaseEnemy

class_name BossEnemy

enum BossPhase { PHASE_1, PHASE_2, PHASE_3 }

signal phase_changed(new_phase)

@export var primary_mutation: MutatedEnemy.MutationType
@export var secondary_mutation: MutatedEnemy.MutationType

var current_phase: BossPhase = BossPhase.PHASE_1
var phase_health_thresholds: Array = [0.6, 0.3]  # 60% and 30% health triggers phase changes

# Debug variables
var debug_mode: bool = false

func _ready():
    super._ready()
    max_health *= 4  # Bosses have 4x health of basic enemies
    health = max_health
    attack_power *= 2

func _physics_process(delta):
    super._physics_process(delta)
    check_phase_transition()

func attack():
    super.attack()
    apply_mutation_effect(primary_mutation)
    
    if current_phase != BossPhase.PHASE_1:
        apply_mutation_effect(secondary_mutation)

func apply_mutation_effect(mutation: MutatedEnemy.MutationType):
    match mutation:
        MutatedEnemy.MutationType.EXPLOSION:
            create_explosion()
        MutatedEnemy.MutationType.FLAME:
            create_flame_trail()
        MutatedEnemy.MutationType.ELECTRICITY:
            create_electric_field()
        MutatedEnemy.MutationType.WATER:
            create_water_splash()
        MutatedEnemy.MutationType.FREEZE:
            create_freeze_zone()
        MutatedEnemy.MutationType.TOXIC:
            create_toxic_cloud()
        MutatedEnemy.MutationType.ACID:
            create_acid_pool()

func create_explosion():
    print("Boss created an explosion")
    # Implement explosion effect

func create_flame_trail():
    print("Boss created a flame trail")
    # Implement flame trail effect

func create_electric_field():
    print("Boss created an electric field")
    # Implement electric field effect

func create_water_splash():
    print("Boss created a water splash")
    # Implement water splash effect

func create_freeze_zone():
    print("Boss created a freeze zone")
    # Implement freeze zone effect

func create_toxic_cloud():
    print("Boss created a toxic cloud")
    # Implement toxic cloud effect

func create_acid_pool():
    print("Boss created an acid pool")
    # Implement acid pool effect

func take_damage(amount: float):
    if player.mutation_system.get_current_mutation() == primary_mutation or \
       player.mutation_system.get_current_mutation() == secondary_mutation:
        amount *= 0.75  # 25% damage reduction against primary and secondary mutations
    super.take_damage(amount)

func check_phase_transition():
    var health_percentage = health / max_health
    if current_phase == BossPhase.PHASE_1 and health_percentage <= phase_health_thresholds[0]:
        transition_to_phase(BossPhase.PHASE_2)
    elif current_phase == BossPhase.PHASE_2 and health_percentage <= phase_health_thresholds[1]:
        transition_to_phase(BossPhase.PHASE_3)

func transition_to_phase(new_phase: BossPhase):
    current_phase = new_phase
    emit_signal("phase_changed", new_phase)
    match new_phase:
        BossPhase.PHASE_2:
            print("Boss entering Phase 2")
            attack_power *= 1.2
            move_speed *= 1.1
        BossPhase.PHASE_3:
            print("Boss entering Phase 3")
            attack_power *= 1.3
            move_speed *= 1.2
    # Implement phase transition effects or spawn minions here

func die():
    print("Boss defeated!")
    # Implement special death sequence for boss
    # This could include a cutscene, dropping special items, etc.
    super.die()

# Debug functions
func toggle_debug_mode():
    debug_mode = !debug_mode
    print("Boss Enemy debug mode: ", "ON" if debug_mode else "OFF")

func debug_print_info():
    print("Boss Enemy Info:")
    print(f"  Health: {health}/{max_health}")
    print(f"  Current Phase: {BossPhase.keys()[current_phase]}")
    print(f"  Attack Power: {attack_power}")
    print(f"  Move Speed: {move_speed}")
    print(f"  Primary Mutation: {MutatedEnemy.MutationType.keys()[primary_mutation]}")
    print(f"  Secondary Mutation: {MutatedEnemy.MutationType.keys()[secondary_mutation]}")

func debug_set_phase(phase: String):
    var new_phase = BossPhase.get(phase.to_upper())
    if new_phase != null:
        transition_to_phase(new_phase)
        print(f"Boss phase set to: {phase}")
    else:
        print(f"Invalid boss phase: {phase}")

func debug_trigger_mutation_effect(mutation: String):
    var mutation_type = MutatedEnemy.MutationType.get(mutation.to_upper())
    if mutation_type != null:
        apply_mutation_effect(mutation_type)
        print(f"Triggered mutation effect: {mutation}")
    else:
        print(f"Invalid mutation type: {mutation}")

func debug_set_health_percentage(percentage: float):
    health = max_health * clamp(percentage, 0, 1)
    print(f"Boss health set to {percentage * 100}%")
    check_phase_transition()

# Add any additional boss-related methods here
