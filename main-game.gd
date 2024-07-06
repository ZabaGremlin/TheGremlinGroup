extends Node

var player: CharacterBody2D
var level_manager: Node
var environmental_system: Node
var secret_area_system: Node
var item_system: Node
var ui_manager: Node
var save_system: Node
var multiplayer_manager: Node
var tools_system: Node

# Debug variables
var debug_mode: bool = false

func _ready():
    initialize_systems()
    load_game_data()
    start_game()

func initialize_systems():
    player = $Player
    level_manager = $LevelManager
    environmental_system = $EnvironmentalSystem
    secret_area_system = $SecretAreaSystem
    item_system = $ItemSystem
    ui_manager = $UIManager
    save_system = get_node("/root/SaveLoadSystem")
    multiplayer_manager = $MultiplayerManager
    tools_system = $ToolsSystem

    level_manager.initialize(player)
    environmental_system.initialize()
    secret_area_system.initialize()
    item_system.initialize()
    ui_manager.initialize()
    multiplayer_manager.initialize()
    tools_system.initialize()
    
    # Connect signals
    player.connect("died", Callable(self, "_on_player_died"))
    player.inventory_system.connect("item_collected", Callable(self, "_on_item_collected"))
    player.mutation_system.connect("mutation_absorbed", Callable(self, "_on_mutation_absorbed"))
    level_manager.connect("level_completed", Callable(self, "_on_level_completed"))
    level_manager.connect("tool_unlocked", Callable(self, "_on_tool_unlocked"))
    level_manager.connect("wearable_unlocked", Callable(self, "_on_wearable_unlocked"))
    level_manager.connect("health_bonus_awarded", Callable(self, "_on_health_bonus_awarded"))
    level_manager.connect("key_item_awarded", Callable(self, "_on_key_item_awarded"))
    level_manager.connect("moon_water_unlocked", Callable(self, "_on_moon_water_unlocked"))
    ui_manager.game_menu.connect("save_game_requested", Callable(self, "save_game"))
    ui_manager.game_menu.connect("quit_game_requested", Callable(self, "quit_game"))

func load_game_data():
    var game_data = save_system.load_latest_game()
    if game_data:
        apply_game_data(game_data)
    else:
        # If no save data, start a new game
        player.initialize_character()
        level_manager.current_level = "gremland_village"

func apply_game_data(game_data):
    player.gremlin_type = player.GremlinType[game_data.selected_character.to_upper()]
    player.initialize_character()
    level_manager.current_level = game_data.current_level
    player.health_system.set_health(game_data.player_health)
    player.mutation_system.set_mutation(game_data.current_mutation)
    player.inventory_system.load_inventory(game_data.inventory)
    level_manager.load_completed_levels(game_data.completed_levels)
    tools_system.load_tools_data(game_data.tools_data)
    # Apply more game data as needed

func start_game():
    level_manager.load_level(level_manager.current_level)
    ui_manager.update_ui()

func _process(delta):
    if debug_mode:
        update_debug_info()

func _unhandled_input(event):
    if event.is_action_pressed("pause"):
        ui_manager.toggle_game_menu()
    elif event.is_action_pressed("debug_toggle"):
        toggle_debug_mode()
    elif event.is_action_pressed("quick_save") and debug_mode:
        save_game()

func _on_level_completed(level_name: String):
    level_manager.complete_level(level_name)
    var next_level = level_manager.get_next_level()
    if next_level:
        level_manager.load_level(next_level)
    else:
        end_game()

func end_game():
    # Implement game over or victory logic here
    get_tree().change_scene_to_file("res://scenes/EndGameScreen.tscn")

func _on_player_died():
    # Implement game over logic here
    get_tree().change_scene_to_file("res://scenes/GameOverScreen.tscn")

func _on_item_collected(item_type):
    var new_item = item_system.create_item(item_type)
    player.inventory_system.add_item(new_item)

func _on_mutation_absorbed(mutation_type):
    player.mutation_system.absorb_power(mutation_type)

func _on_tool_unlocked(tool_type):
    tools_system.unlock_tool(tool_type)
    ui_manager.show_tool_unlocked_notification(tool_type)

func _on_wearable_unlocked(wearable_type):
    item_system.unlock_wearable(wearable_type)
    ui_manager.show_wearable_unlocked_notification(wearable_type)

func _on_health_bonus_awarded():
    player.health_system.increase_max_health()
    ui_manager.show_health_bonus_notification()

func _on_key_item_awarded(item_name: String):
    player.inventory_system.add_key_item(item_name)
    ui_manager.show_key_item_notification(item_name)

func _on_moon_water_unlocked():
    player.ability_system.unlock_moon_water()
    ui_manager.show_moon_water_unlocked_notification()

func save_game(slot: int = -1):
    var save_data = {
        "selected_character": player.character_name,
        "current_level": level_manager.current_level,
        "player_health": player.health_system.get_health(),
        "current_mutation": player.mutation_system.get_current_mutation(),
        "inventory": player.inventory_system.get_save_data(),
        "completed_levels": level_manager.get_completed_levels(),
        "tools_data": tools_system.get_save_data(),
        "player_position": player.global_position,
        "ability_system": player.ability_system.get_save_data(),
        # Add more game state data as needed
    }
    save_system.save_game(save_data, slot)
    ui_manager.show_save_notification()

func load_game(slot: int):
    var game_data = save_system.load_game(slot)
    if game_data:
        apply_game_data(game_data)
        return true
    return false

func quit_game():
    # Optionally save the game before quitting
    save_game()
    # Return to the title screen
    get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")

# Debug functions
func toggle_debug_mode():
    debug_mode = !debug_mode
    player.toggle_debug_mode()
    level_manager.toggle_debug_mode()
    environmental_system.toggle_debug_mode()
    secret_area_system.toggle_debug_mode()
    item_system.toggle_debug_mode()
    ui_manager.toggle_debug_mode()
    tools_system.toggle_debug_mode()
    print("Main Game debug mode: ", "ON" if debug_mode else "OFF")

func update_debug_info():
    var debug_text = "Debug Info:\n"
    debug_text += f"Current Level: {level_manager.current_level}\n"
    debug_text += f"Player Position: {player.global_position}\n"
    debug_text += f"Player Health: {player.health_system.get_health()}/{player.health_system.get_max_health()}\n"
    debug_text += f"Current Mutation: {player.mutation_system.get_current_mutation()}\n"
    debug_text += f"Inventory Items: {player.inventory_system.get_item_count()}\n"
    debug_text += f"Unlocked Tools: {tools_system.get_unlocked_tools_count()}\n"
    ui_manager.update_debug_panel(debug_text)

func debug_complete_current_level():
    level_manager.complete_level(level_manager.current_level)
    print(f"Debug: Completed level {level_manager.current_level}")

func debug_spawn_all_items():
    var items = item_system.debug_create_all_items()
    for item in items:
        player.inventory_system.add_item(item)
    print("All items spawned in player inventory")

func debug_unlock_all_mutations():
    for mutation in player.mutation_system.MutationType.values():
        if mutation != player.mutation_system.MutationType.NONE:
            player.mutation_system.absorb_power(mutation)
    print("All mutations unlocked")

func debug_teleport_to_level_start():
    player.global_position = level_manager.get_player_spawn_position()
    print("Player teleported to level start")

func debug_unlock_all_tools():
    tools_system.debug_unlock_all_tools()
    print("All tools unlocked")

func debug_max_out_player_stats():
    player.health_system.set_health(player.health_system.get_max_health())
    player.ability_system.set_water(player.ability_system.get_max_water())
    print("Player stats maxed out")

func debug_toggle_invincibility():
    player.health_system.toggle_invincibility()
    print("Player invincibility toggled")

func debug_toggle_infinite_water():
    player.ability_system.toggle_infinite_water()
    print("Infinite water toggled")

# Add any additional game management methods here
