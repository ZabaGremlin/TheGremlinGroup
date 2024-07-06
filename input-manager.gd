extends Node

signal input_mode_changed(new_mode)

enum InputMode { KEYBOARD_MOUSE, GAMEPAD }

var current_input_mode: InputMode = InputMode.KEYBOARD_MOUSE
var players: Array = []

# Thresholds for analog inputs
const DEADZONE: float = 0.2
const AIM_ANGLE_SNAP: float = 15.0  # Degrees

# Input actions
const ACTIONS = {
    "move_left": "move_left",
    "move_right": "move_right",
    "jump": "jump",
    "attack": "attack",
    "use_tool": "use_tool",
    "use_item": "use_item",
    "cycle_tool": "cycle_tool",
    "cycle_item": "cycle_item",
    "aim_up": "aim_up",
    "aim_down": "aim_down",
    "aim_left": "aim_left",
    "aim_right": "aim_right"
}

# Debug variables
var debug_mode: bool = false

func _ready():
    set_process_input(true)

func _input(event):
    detect_input_mode(event)

func detect_input_mode(event):
    var new_mode = current_input_mode
    if event is InputEventKey or event is InputEventMouse:
        new_mode = InputMode.KEYBOARD_MOUSE
    elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
        new_mode = InputMode.GAMEPAD
    
    if new_mode != current_input_mode:
        current_input_mode = new_mode
        emit_signal("input_mode_changed", current_input_mode)
        if debug_mode:
            print(f"Input mode changed to: {InputMode.keys()[current_input_mode]}")

func get_movement_vector(player_index: int) -> Vector2:
    var move_vector = Vector2.ZERO
    
    if current_input_mode == InputMode.KEYBOARD_MOUSE:
        move_vector.x = Input.get_action_strength(ACTIONS.move_right) - Input.get_action_strength(ACTIONS.move_left)
    else:
        move_vector.x = Input.get_joy_axis(player_index, JOY_AXIS_LEFT_X)
        
    move_vector.y = Input.get_action_strength(ACTIONS.jump) if Input.is_action_just_pressed(ACTIONS.jump) else 0
    
    return move_vector if move_vector.length() > DEADZONE else Vector2.ZERO

func get_aim_vector(player_index: int) -> Vector2:
    var aim_vector = Vector2.ZERO
    
    if current_input_mode == InputMode.KEYBOARD_MOUSE:
        aim_vector = get_global_mouse_position() - players[player_index].global_position
    else:
        aim_vector.x = Input.get_joy_axis(player_index, JOY_AXIS_RIGHT_X)
        aim_vector.y = Input.get_joy_axis(player_index, JOY_AXIS_RIGHT_Y)
        
        # Apply angle snapping for gamepad
        if aim_vector.length() > DEADZONE:
            var angle = aim_vector.angle()
            var snapped_angle = round(angle / deg_to_rad(AIM_ANGLE_SNAP)) * deg_to_rad(AIM_ANGLE_SNAP)
            aim_vector = Vector2.RIGHT.rotated(snapped_angle) * aim_vector.length()
    
    return aim_vector.normalized()

func is_action_just_pressed(action: String, player_index: int = 0) -> bool:
    if current_input_mode == InputMode.GAMEPAD:
        return Input.is_joy_button_pressed(player_index, Input.get_joy_button_index_from_action(action))
    return Input.is_action_just_pressed(action)

func is_action_pressed(action: String, player_index: int = 0) -> bool:
    if current_input_mode == InputMode.GAMEPAD:
        return Input.is_joy_button_pressed(player_index, Input.get_joy_button_index_from_action(action))
    return Input.is_action_pressed(action)

func register_player(player: Node):
    players.append(player)

func unregister_player(player: Node):
    players.erase(player)

# Debug functions
func toggle_debug_mode():
    debug_mode = !debug_mode
    print("Input Manager debug mode: ", "ON" if debug_mode else "OFF")

func debug_print_input_info():
    print("Input Manager Info:")
    print(f"  Current Input Mode: {InputMode.keys()[current_input_mode]}")
    print(f"  Registered Players: {players.size()}")
    print("  Action States:")
    for action in ACTIONS.values():
        print(f"    {action}: {Input.is_action_pressed(action)}")

func debug_simulate_action(action: String, pressed: bool):
    if ACTIONS.values().has(action):
        Input.action_press(action) if pressed else Input.action_release(action)
        print(f"Simulated action: {action} {'pressed' if pressed else 'released'}")
    else:
        print(f"Invalid action: {action}")

func debug_simulate_gamepad_input(axis: int, value: float):
    Input.joy_axis(0, axis, value)
    print(f"Simulated gamepad input: Axis {axis} set to {value}")

func debug_cycle_input_mode():
    current_input_mode = InputMode.GAMEPAD if current_input_mode == InputMode.KEYBOARD_MOUSE else InputMode.KEYBOARD_MOUSE
    emit_signal("input_mode_changed", current_input_mode)
    print(f"Cycled input mode to: {InputMode.keys()[current_input_mode]}")

# Add more input-related functions as needed
