extends Control

@onready var new_game_button = $VBoxContainer/NewGameButton
@onready var continue_button = $VBoxContainer/ContinueButton
@onready var options_button = $VBoxContainer/OptionsButton
@onready var quit_button = $VBoxContainer/QuitButton

@onready var save_slot_container = $SaveSlotContainer
@onready var character_selection_container = $CharacterSelectionContainer
@onready var options_menu = $OptionsMenu

var save_system: Node

# Debug variables
var debug_mode: bool = false

func _ready():
    save_system = get_node("/root/SaveLoadSystem")
    new_game_button.grab_focus()
    check_for_save_game()

func check_for_save_game():
    var save_slots = save_system.get_save_slots_info()
    continue_button.disabled = save_slots.all(func(slot): return slot.has("empty"))

func _on_new_game_button_pressed():
    show_character_selection()

func _on_continue_button_pressed():
    show_save_slots()

func _on_options_button_pressed():
    show_options_menu()

func _on_quit_button_pressed():
    get_tree().quit()

func show_character_selection():
    character_selection_container.show()
    # Populate character selection UI here

func show_save_slots():
    save_slot_container.show()
    for child in save_slot_container.get_children():
        child.queue_free()
    
    var save_slots = save_system.get_save_slots_info()
    for slot in save_slots:
        var button = Button.new()
        save_slot_container.add_child(button)
        if slot.has("empty"):
            button.text = f"Empty Slot {slot.slot + 1}"
            button.disabled = true
        else:
            var datetime = Time.get_datetime_string_from_unix_time(slot.timestamp)
            button.text = f"Slot {slot.slot + 1}: Level {slot.level}, {datetime}"
        button.connect("pressed", Callable(self, "_on_save_slot_selected").bind(slot.slot))

func _on_save_slot_selected(slot: int):
    save_system.load_game(slot)
    get_tree().change_scene_to_file("res://scenes/MainGame.tscn")

func show_options_menu():
    options_menu.show()

func _on_character_selected(character: String):
    # Start new game with selected character
    var game_data = GameData.new()
    game_data.selected_character = character
    save_system.save_game(game_data, 0)  # Save in slot 0 for new game
    get_tree().change_scene_to_file("res://scenes/MainGame.tscn")

# Debug functions
func toggle_debug_mode():
    debug_mode = !debug_mode
    print("Title Screen debug mode: ", "ON" if debug_mode else "OFF")

func debug_print_info():
    print("Title Screen Info:")
    print(f"  New Game Button Focused: {new_game_button.has_focus()}")
    print(f"  Continue Button Enabled: {not continue_button.disabled}")

func debug_force_new_game():
    show_character_selection()
    print("Forced new game start")

func debug_force_continue():
    show_save_slots()
    print("Forced continue game")
