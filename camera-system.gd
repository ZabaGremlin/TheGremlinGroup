extends Camera2D

@export var follow_speed: float = 5.0
@export var zoom_speed: float = 0.5
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0

var targets: Array = []
var current_zoom: float = 1.0

# Debug variables
var debug_mode: bool = false
var debug_draw: bool = false

func _ready():
    add_target(get_parent())  # Assuming the camera is a child of the player

func _process(delta):
    if not targets.is_empty():
        var target_position = calculate_target_position()
        global_position = global_position.lerp(target_position, follow_speed * delta)
        
        var target_zoom = calculate_target_zoom()
        current_zoom = lerp(current_zoom, target_zoom, zoom_speed * delta)
        zoom = Vector2(current_zoom, current_zoom)

    if debug_draw:
        queue_redraw()

func _draw():
    if debug_draw:
        # Draw camera bounds
        var rect = get_viewport_rect()
        draw_rect(rect, Color.RED, false)
        
        # Draw target positions
        for target in targets:
            var target_pos = target.global_position - global_position
            draw_circle(target_pos, 5, Color.GREEN)

func add_target(target: Node2D):
    if not targets.has(target):
        targets.append(target)

func remove_target(target: Node2D):
    targets.erase(target)

func calculate_target_position() -> Vector2:
    if targets.size() == 1:
        return targets[0].global_position
    else:
        var bounds = Rect2(targets[0].global_position, Vector2.ZERO)
        for target in targets:
            bounds = bounds.expand(target.global_position)
        return bounds.get_center()

func calculate_target_zoom() -> float:
    if targets.size() == 1:
        return 1.0
    else:
        var bounds = Rect2(targets[0].global_position, Vector2.ZERO)
        for target in targets:
            bounds = bounds.expand(target.global_position)
        var screen_size = get_viewport_rect().size
        var x_ratio = screen_size.x / (bounds.size.x + 100)  # Add padding
        var y_ratio = screen_size.y / (bounds.size.y + 100)  # Add padding
        return clamp(min(x_ratio, y_ratio), min_zoom, max_zoom)

func shake(duration: float, intensity: float):
    var shake_tween = create_tween()
    shake_tween.tween_method(Callable(self, "_apply_shake"), intensity, 0.0, duration)

func _apply_shake(intensity: float):
    offset = Vector2(
        randf_range(-intensity, intensity),
        randf_range(-intensity, intensity)
    )

func focus_on_point(point: Vector2, zoom_level: float, duration: float):
    var focus_tween = create_tween()
    focus_tween.tween_property(self, "global_position", point, duration)
    focus_tween.parallel().tween_property(self, "zoom", Vector2(zoom_level, zoom_level), duration)

# Debug functions
func toggle_debug_mode():
    debug_mode = !debug_mode
    debug_draw = debug_mode
    print("Camera System debug mode: ", "ON" if debug_mode else "OFF")

func debug_print_info():
    print("Camera Info:")
    print(f"  Position: {global_position}")
    print(f"  Zoom: {zoom}")
    print(f"  Targets: {targets.size()}")
    for i, target in enumerate(targets):
        print(f"    Target {i}: {target.name} at {target.global_position}")

func debug_add_random_target():
    var random_pos = Vector2(randf_range(-500, 500), randf_range(-500, 500))
    var dummy_target = Node2D.new()
    dummy_target.global_position = random_pos
    add_target(dummy_target)
    get_parent().add_child(dummy_target)
    print(f"Added dummy target at {random_pos}")

func debug_remove_random_target():
    if targets.size() > 1:
        var random_index = randi() % (targets.size() - 1) + 1  # Don't remove the first target (player)
        var removed_target = targets[random_index]
        remove_target(removed_target)
        removed_target.queue_free()
        print(f"Removed target: {removed_target.name}")
    else:
        print("Cannot remove the only target (player)")

func debug_trigger_shake():
    shake(0.5, 10.0)
    print("Triggered camera shake")

func debug_focus_random_point():
    var random_pos = Vector2(randf_range(-500, 500), randf_range(-500, 500))
    focus_on_point(random_pos, 1.5, 1.0)
    print(f"Focusing on random point: {random_pos}")

# Add any additional camera-related methods here
