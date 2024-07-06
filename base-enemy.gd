extends CharacterBody2D

class_name BaseEnemy

enum State { IDLE, PATROL, CHASE, ATTACK, STUNNED, FROZEN }

@export var max_health: float = 100
@export var move_speed: float = 100
@export var attack_power: float = 10
@export var attack_range: float = 50
@export var detection_range: float = 200

var health: float
var current_state: State = State.IDLE
var player: Node2D
var last_attack_time: float = 0
var attack_cooldown: float = 1.0

@onready var animation_player = $AnimationPlayer
@onready var state_timer = $StateTimer

# Debug variables
var debug_mode: bool = false
var invincible: bool = false

func _ready():
    health = max_health
    state_timer.connect("timeout", Callable(self, "_on_state_timer_timeout"))

func _physics_process(delta):
    match current_state:
        State.IDLE:
            handle_idle_state(delta)
        State.PATROL:
            handle_patrol_state(delta)
        State.CHASE:
            handle_chase_state(delta)
        State.ATTACK:
            handle_attack_state(delta)
        State.STUNNED:
            handle_stunned_state(delta)
        State.FROZEN:
            handle_frozen_state(delta)

func handle_idle_state(delta):
    if player and global_position.distance_to(player.global_position) <= detection_range:
        change_state(State.CHASE)
    elif state_timer.is_stopped():
        state_timer.start(randf_range(2, 5))  # Random idle time

func handle_patrol_state(delta):
    # Implement patrol logic here
    pass

func handle_chase_state(delta):
    if player:
        var direction = (player.global_position - global_position).normalized()
        velocity = direction * move_speed
        move_and_slide()
        
        if global_position.distance_to(player.global_position) <= attack_range:
            change_state(State.ATTACK)
    else:
        change_state(State.IDLE)

func handle_attack_state(delta):
    if player and global_position.distance_to(player.global_position) <= attack_range:
        if Time.get_ticks_msec() - last_attack_time > attack_cooldown * 1000:
            attack()
    else:
        change_state(State.CHASE)

func handle_stunned_state(delta):
    # Implement stunned behavior here
    pass

func handle_frozen_state(delta):
    # Implement frozen behavior here
    pass

func attack():
    if player:
        player.take_damage(attack_power)
        last_attack_time = Time.get_ticks_msec()

func take_damage(amount: float):
    if invincible:
        print("Enemy is invincible, no damage taken")
        return
    
    health -= amount
    if health <= 0:
        die()
    else:
        # Implement hit reaction here
        print(f"Enemy took {amount} damage. Current health: {health}")

func die():
    # Implement death behavior here
    print("Enemy died")
    queue_free()

func change_state(new_state: State):
    current_state = new_state
    state_timer.stop()
    
    match new_state:
        State.IDLE:
            animation_player.play("idle")
        State.PATROL:
            animation_player.play("walk")
        State.CHASE:
            animation_player.play("run")
        State.ATTACK:
            animation_player.play("attack")
        State.STUNNED:
            animation_player.play("stunned")
            state_timer.start(3)  # Stunned for 3 seconds
        State.FROZEN:
            animation_player.play("frozen")
            state_timer.start(5)  # Frozen for 5 seconds

func _on_state_timer_timeout():
    match current_state:
        State.IDLE:
            change_state(State.PATROL)
        State.STUNNED, State.FROZEN:
            change_state(State.IDLE)

func initialize(player_node: Node2D):
    player = player_node

# Debug functions
func toggle_debug_mode():
    debug_mode = !debug_mode
    print("Enemy debug mode: ", "ON" if debug_mode else "OFF")

func toggle_invincibility():
    invincible = !invincible
    print("Enemy invincibility: ", "ON" if invincible else "OFF")

func debug_print_info():
    print("Enemy Info:")
    print(f"  Health: {health}/{max_health}")
    print(f"  State: {State.keys()[current_state]}")
    print(f"  Position: {global_position}")
    print(f"  Move Speed: {move_speed}")
    print(f"  Attack Power: {attack_power}")
    print(f"  Attack Range: {attack_range}")
    print(f"  Detection Range: {detection_range}")

func debug_set_state(state: String):
    var new_state = State.get(state.to_upper())
    if new_state != null:
        change_state(new_state)
        print(f"Enemy state changed to: {state}")
    else:
        print(f"Invalid state: {state}")

func debug_teleport(x: float, y: float):
    global_position = Vector2(x, y)
    print(f"Enemy teleported to: ({x}, {y})")

# Add more debug functions as needed
