extends CanvasLayer

signal game_paused
signal game_resumed

@onready var health_bar = $HealthBar
@onready var water_bar = $WaterBar
@onready var mutation_icon = $MutationIcon
@onready var tool_icon = $ToolIcon
@onready var message_label = $MessageLabel
@onready var debug_panel = $DebugPanel
@onready var game_menu = $GameMenu

var character: Node2D
var is_game_paused: bool = false

# Debug variables
var debug_mode: bool = false

func _ready():
    # Connect signals from the character
    character = get_node("/root/Main/Character")
    character.connect("health_changed", Callable(self, "_on_health_changed"))
    character.ability_system.connect("water_changed", Callable(self, "_on_water_changed"))
    character.mutation_system.connect("mutation_changed", Callable(self, "_on_mutation_changed"))
    character.inventory_system.connect("tool_changed", Callable(self, "_on_tool_changed"))
    
    debug_panel.visible = false
    game_menu.visible = false

func _input(event):
    if event.is_action_pressed("toggle_menu"):
        toggle_game_menu()

func _on_health_changed(new_health, max_health):
    health_bar.value = (new_health / max_health) * 100
    if debug_mode:
        print(f"Health updated: {new_health}/{max_health}")

func _on_water_changed(new_water, max_water):
    water_bar.value = (new_water / max_water) * 100
    if debug_mode:
        print(f"Water updated: {new_water}/{max_water}")

func _on_mutation_changed(new_mutation):
    mutation_icon.texture = load("res://assets/mutations/" + str(new_mutation) + ".png")
    if debug_mode:
        print(f"Mutation changed to: {new_mutation}")

func _on_tool_changed(new_tool):
    if new_tool:
        tool_icon.texture = load("res://assets/tools/" + str(new_tool.name) + ".png")
        tool_icon.show()
        if debug_mode:
            print(f"Tool changed to: {new_tool.name}")
    else:
        tool_icon.hide()
        if debug_mode:
            print("Tool unequipped")

func show_message(text: String, duration: float = 2.0):
    message_label.text = text
    message_label.show()
    
    var timer = Timer.new()
    add_child(timer)
    timer.connect("timeout", Callable(self, "_on_message_timer_timeout").bind(timer))
    timer.set_one_shot(true)
    timer.set_wait_time(duration)
    timer.start()

func _on_message_timer_timeout(timer):
    message_label.hide()
    timer.queue_free()

func update_debug_panel():
    if debug_mode:
        var debug_text = "Debug Info:\n"
        debug_text += f"Health: {character.get_health()}/{character.get_max_health()}\n"
        debug_text += f"Water: {character.ability_system.current_water}/{character.ability_system.max_water}\n"
        debug_text += f"Mutation: {character.mutation_system.get_current_mutation()}\n"
        debug_text += f"Position: {character.global_position}\n"
        debug_text += f"State: {character.state_machine.get_state_name()}\n"
        
        debug_panel.text = debug_text

func toggle_game_menu():
    is_game_paused = !is_game_paused
    game_menu.visible = is_game_paused
    get_tree().paused = is_game_paused
    if is_game_paused:
        emit_signal("game_paused")
    else:
        emit_signal("game_resumed")

func show_save_notification():
    show_message("Game Saved", 2.0)

func show_game_over_screen():
    # Implement game over screen logic
    pass

func show_end_game_screen():
    # Implement end game screen logic
    pass

# Debug functions
func toggle_debug_mode():
    debug_mode = !debug_mode
    debug_panel.visible = debug_mode
    print("UI Manager debug mode: ", "ON" if debug_mode else "OFF")

func debug_show_all_ui():
    health_bar.show()
    water_bar.show()
    mutation_icon.show()
    tool_icon.show()
    message_label.show()
    print("All UI elements shown")

func debug_hide_all_ui():
    health_bar.hide()
    water_bar.hide()
    mutation_icon.hide()
    tool_icon.hide()
    message_label.hide()
    print("All UI elements hidden")

func debug_test_message(text: String, duration: float = 2.0):
    show_message(text, duration)
    print(f"Test message shown: '{text}' for {duration} seconds")

# Add more UI-related methods as needed
