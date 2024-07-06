extends Node

signal interaction_occurred(interaction_type, position)

enum InteractableType {
    CRACKED_STONE,
    ICE_WALL,
    WOOD_DOOR,
    MACHINERY,
    PLANT,
    WATER_FLOW,
    ACID_VULNERABLE
}

enum MutationType {
    EXPLOSION,
    FLAME,
    ELECTRICITY,
    WATER,
    FREEZE,
    TOXIC,
    ACID
}

var mutation_interactions = {
    MutationType.EXPLOSION: [InteractableType.CRACKED_STONE],
    MutationType.FLAME: [InteractableType.ICE_WALL, InteractableType.WOOD_DOOR],
    MutationType.ELECTRICITY: [InteractableType.MACHINERY],
    MutationType.WATER: [InteractableType.PLANT],
    MutationType.FREEZE: [InteractableType.WATER_FLOW],
    MutationType.TOXIC: [InteractableType.PLANT],
    MutationType.ACID: [InteractableType.ACID_VULNERABLE]
}

# Debug variables
var debug_mode: bool = false

func can_interact(mutation: MutationType, object_type: InteractableType) -> bool:
    return object_type in mutation_interactions.get(mutation, [])

func perform_interaction(player: Node2D, object: Node) -> void:
    if not object.has_method("interact"):
        return
    
    var object_type = object.get_interaction_type()
    var current_mutation = player.mutation_system.get_current_mutation()
    
    if can_interact(current_mutation, object_type):
        object.interact(current_mutation)
        emit_signal("interaction_occurred", InteractableType.keys()[object_type], object.global_position)
        if debug_mode:
            print(f"Interaction occurred: {MutationType.keys()[current_mutation]} on {InteractableType.keys()[object_type]}")

func register_interactable(object: Node) -> void:
    if not object.is_in_group("interactable"):
        object.add_to_group("interactable")
    if debug_mode:
        print(f"Registered interactable: {object.name}")

# Debug functions
func toggle_debug_mode():
    debug_mode = !debug_mode
    print("Environmental Interaction System debug mode: ", "ON" if debug_mode else "OFF")

func debug_print_interactables():
    print("Registered Interactables:")
    for object in get_tree().get_nodes_in_group("interactable"):
        print(f"  {object.name} at {object.global_position}")

func debug_trigger_interaction(mutation_type: String, object_type: String):
    var mutation = MutationType.get(mutation_type.to_upper())
    var interactable = InteractableType.get(object_type.to_upper())
    if mutation != null and interactable != null:
        if can_interact(mutation, interactable):
            print(f"Interaction possible: {mutation_type} on {object_type}")
        else:
            print(f"Interaction not possible: {mutation_type} on {object_type}")
    else:
        print("Invalid mutation type or object type")

# Add any additional environmental interaction methods here
