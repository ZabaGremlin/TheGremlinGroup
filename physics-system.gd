extends Node

var character: CharacterBody2D
var move_speed: float
var jump_force: float
var gravity: float = 980.0

var movement_vector: Vector2 = Vector2.ZERO

# Debug variables
var debug_mode: bool = false
var no_clip: bool = false

func initialize(_character: CharacterBody2D, _move_speed: float, _jump_force: float):
    character = _character
    move_speed = _move_speed
    jump_force = _jump_force

func apply_physics(delta: float):
    if not no_clip:
        if not character.is_on_floor():
            character.velocity.y += gravity * delta
        
        character.velocity.x = movement_vector.x * move_speed
        
        character.move_and_slide()
    else:
        character.position += movement_vector * move_speed * delta

func set_movement(input_vector: Vector2):
    movement_vector = input_vector

func jump():
    if character.is_on_floor() or no_clip:
        character.velocity.y = -jump_force

func get_velocity() -> Vector2:
    return character.velocity

func set_velocity(new_velocity: Vector2):
    character.velocity = new_velocity

# Debug functions
func toggle_debug_mode():
    debug_mode = !debug_mode
    print("Physics System debug mode: ", "ON" if debug_mode else "OFF")

func toggle_no_clip():
    no_clip = !no_clip
    print("No clip mode: ", "ON" if no_clip else "OFF")

func debug_print_physics_info():
    print("Physics Info:")
    print(f"  Position: {character.global_position}")
    print(f"  Velocity: {character.velocity}")
    print(f"  On Floor: {character.is_on_floor()}")
    print(f"  Move Speed: {move_speed}")
    print(f"  Jump Force: {jump_force}")
    print(f"  Gravity: {gravity}")

func debug_set_gravity(new_gravity: float):
    gravity = new_gravity
    print(f"Gravity set to: {gravity}")

func debug_set_move_speed(new_speed: float):
    move_speed = new_speed
    print(f"Move speed set to: {move_speed}")

func debug_set_jump_force(new_force: float):
    jump_force = new_force
    print(f"Jump force set to: {jump_force}")

# Add any additional physics-related methods here
