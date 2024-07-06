extends Control

signal save_game_requested
signal quit_game_requested

@onready var inventory_tab = $TabContainer/Inventory
@onready var quick_options_tab = $TabContainer/QuickOptions
@onready var quest_log_tab = $TabContainer/QuestLog

@onready var music_slider = $TabContainer/QuickOptions/MusicSlider
@onready var sfx_slider = $TabContainer/QuickOptions/SFXSlider
@onready var save_button = $TabContainer/QuickOptions/SaveButton
@onready var quit_button = $TabContainer/QuickOptions/QuitButton

var inventory_system
var quest_system

func _ready():
    inventory_system = get_node("/root/Main/Character/InventorySystem")
    quest_system = get_node("/root/Main/QuestSystem")
    
    music_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
    sfx_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
    
    save_button.connect("pressed", Callable(self, "_on_save_button_pressed"))
    quit_button.connect("pressed", Callable(self, "_on_quit_button_pressed"))
    
    update_inventory_display()
    update_quest_log_display()

func _on_music_slider_value_changed(value):
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)
    save_settings()

func _on_sfx_slider_value_changed(value):
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value)
    save_settings()

func _on_save_button_pressed():
    emit_signal("save_game_requested")

func _on_quit_button_pressed():
    emit_signal("quit_game_requested")

func update_inventory_display():
    # Clear existing inventory display
    for child in inventory_tab.get_children():
        child.queue_free()
    
    # Display tools
    var tools_container = VBoxContainer.new()
    tools_container.name = "ToolsContainer"
    inventory_tab.add_child(tools_container)
    for tool in inventory_system.tools:
        var tool_button = Button.new()
        tool_button.text = tool.name
        tool_button.connect("pressed", Callable(self, "_on_tool_selected").bind(tool))
        tools_container.add_child(tool_button)
    
    # Display food items
    var food_container = VBoxContainer.new()
    food_container.name = "FoodContainer"
    inventory_tab.add_child(food_container)
    for food in inventory_system.food_items:
        var food_button = Button.new()
        food_button.text = f"{food.name} x{food.quantity}"
        food_button.connect("pressed", Callable(self, "_on_food_selected").bind(food))
        food_container.add_child(food_button)
    
    # Display quest items
    var quest_items_container = VBoxContainer.new()
    quest_items_container.name = "QuestItemsContainer"
    inventory_tab.add_child(quest_items_container)
    for item in inventory_system.quest_items:
        var item_label = Label.new()
        item_label.text = item.name
        quest_items_container.add_child(item_label)

func update_quest_log_display():
    # Clear existing quest log display
    for child in quest_log_tab.get_children():
        child.queue_free()
    
    # Display active quests
    var active_quests = quest_system.get_active_quests()
    for quest in active_quests:
        var quest_label = Label.new()
        quest_label.text = f"{quest.title}\n{quest.description}"
        quest_log_tab.add_child(quest_label)
        
        for objective in quest.objectives:
            var objective_label = Label.new()
            objective_label.text = f"- {objective.description}: {objective.current_progress}/{objective.required_progress}"
            quest_log_tab.add_child(objective_label)

func _on_tool_selected(tool):
    inventory_system.equip_tool(tool)

func _on_food_selected(food):
    inventory_system.use_food(food)

func save_settings():
    var settings = {
        "music_volume": music_slider.value,
        "sfx_volume": sfx_slider.value,
    }
    var file = FileAccess.open("user://settings.save", FileAccess.WRITE)
    file.store_var(settings)
    file.close()

# Debug functions
func debug_print_menu_state():
    print("Game Menu State:")
    print(f"  Current Tab: {$TabContainer.current_tab}")
    print(f"  Music Volume: {music_slider.value}")
    print(f"  SFX Volume: {sfx_slider.value}")
    print("  Inventory:")
    print(f"    Tools: {inventory_system.tools.size()}")
    print(f"    Food Items: {inventory_system.food_items.size()}")
    print(f"    Quest Items: {inventory_system.quest_items.size()}")
    print(f"  Active Quests: {quest_system.get_active_quests().size()}")

func debug_add_test_items():
    # Add test items to inventory
    inventory_system.add_item({"name": "Test Tool", "type": "tool"})
    inventory_system.add_item({"name": "Test Food", "type": "food", "quantity": 5})
    inventory_system.add_item({"name": "Test Quest Item", "type": "quest"})
    update_inventory_display()
    print("Test items added to inventory")

func debug_add_test_quest():
    # Add a test quest
    var test_quest = quest_system.Quest.new(
        "test_quest",
        "Test Quest",
        "This is a test quest",
        [quest_system.Objective.new("obj1", "Complete test objective", 3)]
    )
    quest_system.add_quest(test_quest)
    update_quest_log_display()
    print("Test quest added")

# Add more debug functions as needed
