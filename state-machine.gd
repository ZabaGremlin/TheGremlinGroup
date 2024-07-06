extends Node

signal state_changed(old_state, new_state)

enum State { IDLE, MOVE, JUMP, FALL, ATTACK, USE_TOOL, STUNNED, INTERACT, TRANSFORM, GRAPPLING, GLIDING }

var current_state: State = State.IDLE
var previous_state: State = State.IDLE

@onready var character = get_parent()

# Debug variables
var debug_mode: bool = false

func _ready():
    pass

func _physics_process(delta):
    match current_state:
        State.IDLE:
            handle_idle_state(delta)
        State.MOVE:
            handle_move_state(delta)
        State.JUMP:
            handle_jump_state(delta)
        State.FALL:
            handle_fall_state(delta)
        State.ATTACK:
            handle_attack_state(delta)
        State.USE_TOOL:
            handle_use_tool_state(delta)
        State.STUNNED:
            handle_stunned_state(delta)
        State.INTERACT:
            handle_interact_state(delta)
        State.TRANSFORM:
            handle_transform_state(delta)
        State.GRAPPLING:
            handle_grappling_state(delta)
        State.GLIDING:
            handle_gliding_state(delta)

func change_state(new_state: State):
    if current_state != new_state:
        previous_state = current_state
        current_state = new_state
        emit_signal("state_changed", State.keys()[previous_state], State.keys()[new_state])
        if debug_mode:
            print(f"State changed from {State.keys()[previous_state]} to {State.keys()[new_state]}")

func handle_idle_state(delta):
    # Implement idle state logic
    pass

func handle_move_state(delta):
    # Implement move state logic
    pass

func handle_jump_state(delta):
    # Implement jump state logic
    if character.is_on_floor():
        change_state(State.IDLE)
    elif character.velocity.y > 0:
        change_state(State.FALL)

func handle_fall_state(delta):
    # Implement fall state logic
    if character.is_on_floor():
        change_state(State.IDLE)

func handle_attack_state(delta):
    # Implement attack state logic
    # Change back to previous state when attack animation is finished
    pass

func handle_use_tool_state(delta):
    # Implement use tool state logic
    # Change back to previous state when tool use is finished
    pass

func handle_stunned_state(delta):
    # Implement stunned state logic
    # Change back to idle state when stun duration is over
    pass

func handle_interact_state(delta):
    # Implement interact state logic
    # Change back to previous state when interaction is finished
    pass

func handle_transform_state(delta):
    # Implement transform state logic
    # Change to appropriate state when transformation is complete
    pass

func handle_grappling_state(delta):
    # Implement grappling state logic
    # Change to appropriate state when grappling is finished
    pass

func handle_gliding_state(delta):
    # Implement gliding state logic
    # Change to fall state if gliding is cancelled or finished
    pass

func get_state_name() -> String:
    return State.keys()[current_state]

# Debug functions
func toggle_debug_mode():
    debug_mode = !debug_mode
    print("State Machine debug mode: ", "ON" if debug_mode else "OFF")

func debug_print_state_info():
    print("State Machine Info:")
    print(f"  Current State: {State.keys()[current_state]}")
    print(f"  Previous State: {State.keys()[previous_state]}")

func debug_force_state(state_name: String):
    var new_state = State.get(state_name.to_upper())
    if new_state != null:
        change_state(new_state)
        print(f"Forced state change to: {state_name}")
    else:
        print(f"Invalid state name: {state_name}")

func debug_cycle_state():
    var next_state = (current_state + 1) % State.size()
    change_state(next_state)
    print(f"Cycled to next state: {State.keys()[next_state]}")

# Add any additional state-related methods here
