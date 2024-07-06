extends Node

signal interaction_possible(object)
signal interaction_ended
signal interaction_performed(object)

@export var interaction_distance: float = 100.0

var character: CharacterBody2D
var current_interactable = null

@onready var ray_cast = $RayCast2D

# Debug variables
var debug_mode: bool = false

func initialize(_character: CharacterBody2D):
    character = _character
    ray_cast.set_collision_mask_bit(2, true)  # Assuming interactable objects are on layer 3

func _physics_process(delta):
    check_for_interactable()

func check_for_interactable():
    if ray_cast.is_colliding():
        var collider = ray_cast.get_collider()
        if collider.is_in_group("interactable") and collider != current_interactable:
            current_interactable = collider
            emit_signal("interaction_possible", current_interactable)
            if debug_mode:
                print(f"Interaction possible with: {current_interactable.name}")
    elif current_interactable:
        current_interactable = null
        emit_signal("interaction_ended")
        if debug_mode:
            print("Interaction ended")

func interact():
    if current_interactable:
        match current_interactable.interaction_type:
            "npc":
                start_dialogue(current_interactable)
            "item":
                pickup_item(current_interactable)
            "lever":
                toggle_lever(current_interactable)
            "door":
                open_door(current_interactable)
            _:
                print("Unknown interaction type")
        emit_signal("interaction_performed", current_interactable)
        if debug_mode:
            print(f"Interacted with: {current_interactable.name}")

func start_dialogue(npc):
    # Implement dialogue system interaction
    print(f"Starting dialogue with {npc.name}")

func pickup_item(item):
    if character.inventory_system.add_item(item):
        item.queue_free()
        if debug_mode:
            print(f"Picked up item: {item.name}")

func toggle_lever(lever):
    lever.toggle()
    if debug_mode:
        print(f"Toggled lever: {lever.name}")

func open_door(door):
    door.open()
    if debug_mode:
        print(f"Opened door: {door.name}")

# Debug functions
func toggle_debug_mode():
    debug_mode = !debug_mode
    print("Interaction System debug mode: ", "ON" if debug_mode else "OFF")

func debug_print_interactable_info():
    if current_interactable:
        print("Current Interactable:")
        print(f"  Name: {current_interactable.name}")
        print(f"  Type: {current_interactable.interaction_type}")
        print(f"  Position: {current_interactable.global_position}")
    else:
        print("No current interactable")

func debug_force_interaction():
    if current_interactable:
        interact()
    else:
        print("No interactable to force interaction with")

func debug_set_interaction_distance(distance: float):
    interaction_distance = distance
    print(f"Interaction distance set to: {interaction_distance}")

# Add more interaction methods as needed
