extends Node

signal secret_area_revealed(area_id)

var secret_areas = {}

# Debug variables
var debug_mode: bool = false

func register_secret_area(area_id: String, area_node: Node, required_mutation: MutationType) -> void:
    secret_areas[area_id] = {
        "node": area_node,
        "mutation": required_mutation,
        "revealed": false
    }
    if debug_mode:
        print(f"Registered secret area: {area_id}")

func can_reveal_secret(area_id: String, current_mutation: MutationType) -> bool:
    if area_id not in secret_areas:
        return false
    return secret_areas[area_id]["mutation"] == current_mutation and not secret_areas[area_id]["revealed"]

func reveal_secret(area_id: String) -> void:
    if area_id in secret_areas and not secret_areas[area_id]["revealed"]:
        secret_areas[area_id]["revealed"] = true
        secret_areas[area_id]["node"].reveal()
        emit_signal("secret_area_revealed", area_id)
        if debug_mode:
            print(f"Revealed secret area: {area_id}")

func check_nearby_secrets(player: Node2D, current_mutation: MutationType, check_range: float) -> void:
    for area_id in secret_areas:
        var area = secret_areas[area_id]
        if not area["revealed"] and area["node"].global_position.distance_to(player.global_position) <= check_range:
            if can_reveal_secret(area_id, current_mutation):
                reveal_secret(area_id)

func get_revealed_secrets() -> Array:
    var revealed = []
    for area_id in secret_areas:
        if secret_areas[area_id]["revealed"]:
            revealed.append(area_id)
    return revealed

# Debug functions
func toggle_debug_mode():
    debug_mode = !debug_mode
    print("Secret Area System debug mode: ", "ON" if debug_mode else "OFF")

func debug_print_secret_areas():
    print("Secret Areas:")
    for area_id in secret_areas:
        var area = secret_areas[area_id]
        print(f"  ID: {area_id}")
        print(f"    Required Mutation: {MutationType.keys()[area['mutation']]}")
        print(f"    Revealed: {area['revealed']}")
        print(f"    Position: {area['node'].global_position}")

func debug_reveal_all_secrets():
    for area_id in secret_areas:
        reveal_secret(area_id)
    print("All secret areas revealed")

func debug_reset_all_secrets():
    for area_id in secret_areas:
        secret_areas[area_id]["revealed"] = false
        secret_areas[area_id]["node"].hide()
    print("All secret areas reset")

# Add any additional secret area-related methods here
