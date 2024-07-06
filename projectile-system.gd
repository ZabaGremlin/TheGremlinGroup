extends Node

signal projectile_created(projectile)
signal projectile_destroyed(projectile)

var active_projectiles: Array = []

# Debug variables
var debug_mode: bool = false
var infinite_projectiles: bool = false

func create_projectile(projectile_scene: PackedScene, start_position: Vector2, direction: Vector2, speed: float, damage: float):
    var projectile = projectile_scene.instantiate()
    projectile.position = start_position
    projectile.direction = direction
    projectile.speed = speed
    projectile.damage = damage
    
    add_child(projectile)
    active_projectiles.append(projectile)
    
    projectile.connect("tree_exiting", Callable(self, "_on_projectile_destroyed").bind(projectile))
    emit_signal("projectile_created", projectile)
    
    if debug_mode:
        print(f"Projectile created at {start_position} with speed {speed} and damage {damage}")

func _on_projectile_destroyed(projectile):
    active_projectiles.erase(projectile)
    emit_signal("projectile_destroyed", projectile)
    
    if debug_mode:
        print(f"Projectile destroyed at {projectile.position}")

func _physics_process(delta):
    for projectile in active_projectiles:
        projectile.global_position += projectile.direction * projectile.speed * delta
        
        if debug_mode:
            update_projectile_debug_label(projectile)

func clear_all_projectiles():
    for projectile in active_projectiles:
        projectile.queue_free()
    active_projectiles.clear()
    
    if debug_mode:
        print("All projectiles cleared")

# Debug functions
func toggle_debug_mode():
    debug_mode = !debug_mode
    print("Projectile System debug mode: ", "ON" if debug_mode else "OFF")
    
    for projectile in active_projectiles:
        toggle_projectile_debug_label(projectile)

func toggle_infinite_projectiles():
    infinite_projectiles = !infinite_projectiles
    print("Infinite projectiles: ", "ON" if infinite_projectiles else "OFF")

func debug_print_projectile_info():
    print("Active Projectiles:")
    for i, projectile in enumerate(active_projectiles):
        print(f"Projectile {i + 1}:")
        print(f"  Position: {projectile.global_position}")
        print(f"  Direction: {projectile.direction}")
        print(f"  Speed: {projectile.speed}")
        print(f"  Damage: {projectile.damage}")

func toggle_projectile_debug_label(projectile):
    if debug_mode:
        if not projectile.has_node("DebugLabel"):
            var label = Label.new()
            label.name = "DebugLabel"
            projectile.add_child(label)
    else:
        if projectile.has_node("DebugLabel"):
            projectile.get_node("DebugLabel").queue_free()

func update_projectile_debug_label(projectile):
    if projectile.has_node("DebugLabel"):
        var label = projectile.get_node("DebugLabel")
        label.text = f"Pos: {projectile.global_position}\nSpeed: {projectile.speed}\nDamage: {projectile.damage}"

func debug_create_test_projectile(position: Vector2):
    var test_projectile_scene = load("res://scenes/TestProjectile.tscn")
    create_projectile(test_projectile_scene, position, Vector2.RIGHT, 200, 10)
    print("Test projectile created")

# Add more projectile-related methods as needed
