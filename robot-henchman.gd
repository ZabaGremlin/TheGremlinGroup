extends BaseEnemy

class_name RobotHenchman

enum RobotType { CLOSE_RANGE, LONG_RANGE, MEDIUM_RANGE }

@export var robot_type: RobotType

@onready var projectile_spawn = $ProjectileSpawn
@onready var animation_player = $AnimationPlayer

# Debug variables
var debug_mode: bool = false

func _ready():
    super._ready()
    initialize_robot_type()

func initialize_robot_type():
    match robot_type:
        RobotType.CLOSE_RANGE:
            max_health *= 1.5
            move_speed *= 1.2
            attack_range = 50
        RobotType.LONG_RANGE:
            max_health *= 0.8
            move_speed *= 0.8
            attack_range = 300
        RobotType.MEDIUM_RANGE:
            attack_range = 150
    
    health = max_health

func attack():
    match robot_type:
        RobotType.CLOSE_RANGE:
            perform_close_range_attack()
        RobotType.LONG_RANGE:
            perform_long_range_attack()
        RobotType.MEDIUM_RANGE:
            perform_medium_range_attack()

func perform_close_range_attack():
    if player and global_position.distance_to(player.global_position) <= attack_range:
        player.take_damage(attack_power)
        animation_player.play("close_range_attack")
        if debug_mode:
            print("Robot performed close range attack")

func perform_long_range_attack():
    var projectile = preload("res://scenes/Projectile.tscn").instantiate()
    projectile.initialize(projectile_spawn.global_position, player.global_position, attack_power)
    get_tree().current_scene.add_child(projectile)
    animation_player.play("long_range_attack")
    if debug_mode:
        print("Robot performed long range attack")

func perform_medium_range_attack():
    if player and global_position.distance_to(player.global_position) <= attack_range:
        player.take_damage(attack_power * 0.8)
        player.apply_stun(1.0)  # Apply 1 second stun
        animation_player.play("medium_range_attack")
        if debug_mode:
            print("Robot performed medium range attack")

func take_damage(amount: float):
    # Robots take full damage from all types
    super.take_damage(amount)
    animation_player.play("take_damage")

func die():
    # Robots don't drop mutation power-ups
    animation_player.play("die")
    if debug_mode:
        print("Robot destroyed")
    await animation_player.animation_finished
    super.die()

# Debug functions
func toggle_debug_mode():
    debug_mode = !debug_mode
    print("Robot Henchman debug mode: ", "ON" if debug_mode else "OFF")

func debug_print_info():
    print("Robot Henchman Info:")
    print(f"  Type: {RobotType.keys()[robot_type]}")
    print(f"  Health: {health}/{max_health}")
    print(f"  Attack Power: {attack_power}")
    print(f"  Move Speed: {move_speed}")
    print(f"  Attack Range: {attack_range}")
    print(f"  Position: {global_position}")
    print(f"  Current State: {State.keys()[current_state]}")

func debug_set_type(type: String):
    var new_type = RobotType.get(type.to_upper())
    if new_type != null:
        robot_type = new_type
        initialize_robot_type()
        print(f"Robot type set to: {type}")
    else:
        print(f"Invalid robot type: {type}")

func debug_perform_attack():
    attack()
    print("Forced robot to perform attack")

# Add any additional robot henchman-related methods here
