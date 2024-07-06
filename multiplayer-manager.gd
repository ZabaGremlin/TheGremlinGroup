extends Node

signal player_added(player)
signal player_removed(player)

const MAX_PLAYERS = 4
const GREMLIN_TYPES = ["Gremli", "Gremani", "Grey", "Gretchen"]

var players: Array = []
var ai_controlled_characters: Array = []
var available_characters: Array = GREMLIN_TYPES.duplicate()

@onready var camera = get_node("../Camera2D")
@onready var inventory_system = get_node("../InventorySystem")
@onready var ui_manager = get_node("../UIManager")

# Debug variables
var debug_mode: bool = false

func _ready():
    initialize_players()

func initialize_players():
    # Start with Player 1
    add_player()

func add_player():
    if players.size() < MAX_PLAYERS:
        var new_player = create_player(players.size())
        players.append(new_player)
        add_child(new_player)
        update_camera()
        emit_signal("player_added", new_player)
        show_character_selection(new_player)
    else:
        print("Maximum number of players reached")

func create_player(player_index: int):
    var player_scene = load("res://scenes/Player.tscn")
    var player = player_scene.instantiate()
    player.player_index = player_index
    return player

func remove_player(player):
    if players.size() > 1:
        var index = players.find(player)
        if index != -1:
            players.remove_at(index)
            remove_child(player)
            player.queue_free()
            update_camera()
            emit_signal("player_removed", player)
            return_character_to_pool(player.gremlin_type)
    else:
        print("Cannot remove the last player")

func show_character_selection(player):
    # Pause the game
    get_tree().paused = true
    
    # Show character selection UI for this player
    ui_manager.show_character_selection(player, available_characters)

func select_character(player, character_type):
    player.set_gremlin_type(character_type)
    available_characters.erase(character_type)
    
    # If this is the last player to select a character, unpause the game
    if players.size() == MAX_PLAYERS or available_characters.is_empty():
        get_tree().paused = false
    
    # Set up AI for remaining characters
    setup_ai_characters()

func return_character_to_pool(character_type):
    if character_type not in available_characters:
        available_characters.append(character_type)
    setup_ai_characters()

func setup_ai_characters():
    # Remove existing AI characters
    for ai in ai_controlled_characters:
        remove_child(ai)
        ai.queue_free()
    ai_controlled_characters.clear()
    
    # Create AI for remaining characters
    for character_type in available_characters:
        var ai_character = create_player(players.size() + ai_controlled_characters.size())
        ai_character.set_gremlin_type(character_type)
        ai_character.set_ai_controlled(true)
        ai_controlled_characters.append(ai_character)
        add_child(ai_character)

func update_camera():
    var total_pos = Vector2.ZERO
    for player in players:
        total_pos += player.global_position
    camera.global_position = total_pos / players.size()

func update_shared_inventory(item_type):
    inventory_system.add_shared_item(item_type)
    for player in players:
        player.update_quick_slots()

func use_shared_item(item_type, player):
    if inventory_system.use_shared_item(item_type):
        player.apply_item_effect(item_type)

func can_damage(attacker, target):
    return attacker != target  # Players can't damage themselves or each other

func _process(delta):
    # Check for player join/drop inputs
    if Input.is_action_just_pressed("join_game"):
        add_player()
    
    for player in players:
        if Input.is_action_just_pressed("drop_out_p" + str(player.player_index + 1)):
            remove_player(player)

# Debug functions
func toggle_debug_mode():
    debug_mode = !debug_mode
    print("Multiplayer Manager debug mode: ", "ON" if debug_mode else "OFF")

func debug_print_player_info():
    print("Player Information:")
    for i, player in enumerate(players):
        print(f"Player {i + 1}:")
        print(f"  Character: {player.gremlin_type}")
        print(f"  Position: {player.global_position}")
        print(f"  Health: {player.health_system.current_health}/{player.health_system.max_health}")
        print(f"  Current Mutation: {player.mutation_system.get_current_mutation()}")
    print("AI-controlled characters:")
    for i, ai in enumerate(ai_controlled_characters):
        print(f"AI {i + 1}:")
        print(f"  Character: {ai.gremlin_type}")

func debug_add_player():
    add_player()

func debug_remove_random_player():
    if players.size() > 1:
        var random_player = players[randi() % (players.size() - 1) + 1]  # Don't remove Player 1
        remove_player(random_player)
    else:
        print("Cannot remove the only player")

func debug_teleport_all_players(position: Vector2):
    for player in players:
        player.global_position = position
    print(f"Teleported all players to {position}")

# Add more multiplayer-related functions as needed
