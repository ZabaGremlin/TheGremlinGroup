extends Node

enum InteractableType {
    CRACKED_STONE,
    ICE_WALL,
    WOOD_DOOR,
    MACHINERY,
    PLANT,
    WATER_FLOW,
    ACID_VULNERABLE
}

enum MutationType { EXPLOSION, FLAME, ELECTRICITY, WATER, FREEZE, TOXIC, ACID }

# Debug flag
var debug_mode: bool = false

class InteractableObject:
    var interactable_type: InteractableType
    var is_destroyed: bool = false

    func _init(_interactable_type: InteractableType):
        interactable_type = _interactable_type

    func interact(mutation: MutationType):
        print(f"Interacted with {InteractableType.keys()[interactable_type]} using {MutationType.keys()[mutation]}")

    func destroy():
        is_destroyed = true
        print(f"{InteractableType.keys()[interactable_type]} has been destroyed.")

    # Debug method
    func debug_info() -> String:
        return f"Type: {InteractableType.keys()[interactable_type]}, Destroyed: {is_destroyed}"

class CrackedStone extends InteractableObject:
    func _init():
        super._init(InteractableType.CRACKED_STONE)

    func interact(mutation: MutationType):
        if mutation == MutationType.EXPLOSION:
            destroy()
        else:
            print("The cracked stone doesn't react to this mutation.")

    func destroy():
        super.destroy()
        print("The cracked stone crumbles away!")
        # Implement particle effects for destruction
        # Potentially spawn collectibles or reveal hidden areas

class IceWall extends InteractableObject:
    var melting_progress: float = 0

    func _init():
        super._init(InteractableType.ICE_WALL)

    func interact(mutation: MutationType):
        match mutation:
            MutationType.FLAME:
                melt()
            MutationType.FREEZE:
                reinforce()
            _:
                print("The ice wall doesn't react to this mutation.")

    func melt():
        melting_progress += 0.25
        if melting_progress >= 1:
            destroy()
        else:
            print(f"The ice wall is melting! Progress: {melting_progress * 100}%")
            # Update ice wall appearance based on melting progress

    func reinforce():
        melting_progress = max(0, melting_progress - 0.1)
        print(f"The ice wall is reinforced! New strength: {(1 - melting_progress) * 100}%")
        # Update ice wall appearance

    # Override debug_info to include melting progress
    func debug_info() -> String:
        return super.debug_info() + f", Melting Progress: {melting_progress * 100}%"

class WoodDoor extends InteractableObject:
    var is_open: bool = false

    func _init():
        super._init(InteractableType.WOOD_DOOR)

    func interact(mutation: MutationType):
        if mutation == MutationType.FLAME:
            destroy()
        else:
            toggle_door()

    func toggle_door():
        is_open = !is_open
        print(f"Door is now {'open' if is_open else 'closed'}")
        # Implement door opening/closing animation or state change

    # Override debug_info to include door state
    func debug_info() -> String:
        return super.debug_info() + f", Open: {is_open}"

class Machinery extends InteractableObject:
    var is_activated: bool = false

    func _init():
        super._init(InteractableType.MACHINERY)

    func interact(mutation: MutationType):
        if mutation == MutationType.ELECTRICITY:
            toggle_activation()
        else:
            print("The machinery doesn't react to this mutation.")

    func toggle_activation():
        is_activated = !is_activated
        if is_activated:
            activate()
        else:
            deactivate()

    func activate():
        print("The machinery whirs to life!")
        # Implement activation effects (e.g., lights, moving parts)
        # Trigger any game events associated with this machinery

    func deactivate():
        print("The machinery powers down.")
        # Implement deactivation effects

    # Override debug_info to include activation state
    func debug_info() -> String:
        return super.debug_info() + f", Activated: {is_activated}"

class Plant extends InteractableObject:
    var growth_stage: int = 0
    var max_growth_stage: int = 3

    func _init():
        super._init(InteractableType.PLANT)

    func interact(mutation: MutationType):
        match mutation:
            MutationType.WATER:
                grow()
            MutationType.TOXIC:
                wilt()
            _:
                print("The plant doesn't react to this mutation.")

    func grow():
        growth_stage = min(growth_stage + 1, max_growth_stage)
        print(f"The plant has grown! Current stage: {growth_stage}/{max_growth_stage}")
        update_appearance()

    func wilt():
        growth_stage = max(growth_stage - 1, 0)
        print(f"The plant has wilted! Current stage: {growth_stage}/{max_growth_stage}")
        update_appearance()

    func update_appearance():
        # Update the plant's visual appearance based on growth_stage
        pass

    # Override debug_info to include growth stage
    func debug_info() -> String:
        return super.debug_info() + f", Growth Stage: {growth_stage}/{max_growth_stage}"

class WaterFlow extends InteractableObject:
    var is_frozen: bool = false

    func _init():
        super._init(InteractableType.WATER_FLOW)

    func interact(mutation: MutationType):
        match mutation:
            MutationType.FREEZE:
                freeze()
            MutationType.FLAME:
                unfreeze()
            _:
                print("The water flow doesn't react to this mutation.")

    func freeze():
        is_frozen = true
        print("The water flow has frozen!")
        # Implement freezing effect (e.g., change appearance, create ice platform)

    func unfreeze():
        is_frozen = false
        print("The water flow has unfrozen!")
        # Implement unfreezing effect

    # Override debug_info to include frozen state
    func debug_info() -> String:
        return super.debug_info() + f", Frozen: {is_frozen}"

class AcidVulnerable extends InteractableObject:
    var integrity: float = 1.0

    func _init():
        super._init(InteractableType.ACID_VULNERABLE)

    func interact(mutation: MutationType):
        if mutation == MutationType.ACID:
            apply_acid()
        else:
            print("The object doesn't react to this mutation.")

    func apply_acid():
        integrity -= 0.25
        if integrity <= 0:
            destroy()
        else:
            print(f"The object is dissolving! Integrity: {integrity * 100}%")
            update_appearance()

    func update_appearance():
        # Update the object's visual appearance based on integrity
        pass

    # Override debug_info to include integrity
    func debug_info() -> String:
        return super.debug_info() + f", Integrity: {integrity * 100}%"

# Function to create a specific interactable object
func create_interactable(interactable_type: InteractableType) -> InteractableObject:
    match interactable_type:
        InteractableType.CRACKED_STONE:
            return CrackedStone.new()
        InteractableType.ICE_WALL:
            return IceWall.new()
        InteractableType.WOOD_DOOR:
            return WoodDoor.new()
        InteractableType.MACHINERY:
            return Machinery.new()
        InteractableType.PLANT:
            return Plant.new()
        InteractableType.WATER_FLOW:
            return WaterFlow.new()
        InteractableType.ACID_VULNERABLE:
            return AcidVulnerable.new()
        _:
            push_error("Invalid interactable type")
            return null

# Debug functions
func toggle_debug_mode():
    debug_mode = !debug_mode
    print("Debug mode: ", "ON" if debug_mode else "OFF")

func print_all_interactables_info():
    for interactable_type in InteractableType.values():
        var interactable = create_interactable(interactable_type)
        print(interactable.debug_info())

func test_all_interactions():
    for interactable_type in InteractableType.values():
        var interactable = create_interactable(interactable_type)
        print(f"Testing {InteractableType.keys()[interactable_type]}:")
        for mutation in MutationType.values():
            print(f"  Interaction with {MutationType.keys()[mutation]}:")
            interactable.interact(mutation)
        print("---")

func debug_create_all_interactables(position: Vector2):
    var interactables = []
    for interactable_type in InteractableType.values():
        var interactable = create_interactable(interactable_type)
        interactable.position = position + Vector2(interactable_type * 100, 0)  # Spread them out
        interactables.append(interactable)
        add_child(interactable)
    print(f"Created all interactable types at {position}")
    return interactables

func debug_destroy_all_interactables():
    for child in get_children():
        if child is InteractableObject:
            child.queue_free()
    print("Destroyed all interactable objects")

# Add any additional interactable object-related methods here
