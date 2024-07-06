extends CharacterBody2D

enum GremlinType { GREMLI, GREMANI, GREY, GRETCHEN }

signal health_changed(new_health, max_health)
signal died

@export var gremlin_type: GremlinType = GremlinType.GREMLI
@export var speed = 300.0
@export var jump_velocity = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Character-specific attributes
var character_name: String
var special_ability: String
var base_health: int
var base_attack: int

# Additional properties for mutations
var explosion_resistance: bool = false
var fire_resistance: bool = false
var shock_resistance: bool = false
var can_swim: bool = false
var cold_resistance: bool = false
var poison_resistance: bool = false
var acid_resistance: bool = false

@onready var inventory_system = $InventorySystem
@onready var mutation_system = $MutationSystem
@onready var ability_system = $AbilitySystem
@onready var state_machine = $StateMachine
@onready var animation_player = $AnimationPlayer
@onready var tools_system = $ToolsSystem

var current_tool: ToolType = ToolType.WHIP
var is_gliding: bool = false

# Debug variables
var debug_mode: bool = false
var invincible: bool = false

func _ready():
    initialize_character()
    setup_health_bar()
    connect_signals()

func initialize_character():
    match gremlin_type:
        GremlinType.GREMLI:
            character_name = "Gremli"
            special_ability = "Controlled Transformation"
            base_health = 100
            base_attack = 10
        GremlinType.GREMANI:
            character_name = "Gremani"
            special_ability = "Enhanced Mutation"
            base_health = 90
            base_attack = 12
        GremlinType.GREY:
            character_name = "Grey"
            special_ability = "Sneaky"
            base_health = 80
            base_attack = 15
        GremlinType.GRETCHEN:
            character_name = "Gretchen"
            special_ability = "Medic"
            base_health = 120
            base_attack = 8
    
    emit_signal("health_changed", base_health, base_health)

func _physics_process(delta):
    if not is_on_floor():
        velocity.y += gravity * delta

    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity

    var direction = Input.get_axis("move_left", "move_right")
    if direction:
        velocity.x = direction * speed
    else:
        velocity.x = move_toward(velocity.x, 0, speed)

    move_and_slide()

    if Input.is_action_just_pressed("use_tool"):
        use_current_tool()

func use_current_tool():
    var aim_direction = get_global_mouse_position() - global_position
    tools_system.use_tool(current_tool, self, aim_direction, mutation_system.get_current_mutation())

func start_gliding():
    is_gliding = true
    gravity = gravity / 2  # Reduce gravity while gliding

func stop_gliding():
    is_gliding = false
    gravity = ProjectSettings.get_setting("physics/2d/default_gravity")  # Reset gravity

func take_damage(amount: int):
    if invincible:
        print(f"{character_name} is invincible, no damage taken")
        return

    base_health -= amount
    emit_signal("health_changed", base_health, get_max_health())
    if base_health <= 0:
        die()
    else:
        print(f"{character_name} took {amount} damage. Current health: {base_health}")

func die():
    emit_signal("died")
    # Implement death logic here
    print(f"{character_name} has died")

func heal(amount: int):
    base_health = min(base_health + amount, get_max_health())
    emit_signal("health_changed", base_health, get_max_health())
    print(f"{character_name} healed for {amount}. Current health: {base_health}")

func get_health() -> float:
    return base_health

func get_max_health() -> float:
    return inventory_system.get_max_health()

func get_base_attack() -> int:
    return base_attack

# Debug functions
func toggle_debug_mode():
    debug_mode = !debug_mode
    print(f"{character_name} debug mode: ", "ON" if debug_mode else "OFF")

func toggle_invincibility():
    invincible = !invincible
    print(f"{character_name} invincibility: ", "ON" if invincible else "OFF")

func debug_print_info():
    print(f"{character_name} Info:")
    print(f"  Type: {GremlinType.keys()[gremlin_type]}")
    print(f"  Health: {base_health}/{get_max_health()}")
    print(f"  Attack: {base_attack}")
    print(f"  Special Ability: {special_ability}")
    print(f"  Position: {global_position}")
    print(f"  Current Tool: {ToolType.keys()[current_tool]}")
    print(f"  Is Gliding: {is_gliding}")
    mutation_system.debug_print_mutation_info()
    inventory_system.debug_print_inventory()
    ability_system.debug_print_ability_info()
    tools_system.debug_print_tool_info()

# Add any additional character-related methods here
