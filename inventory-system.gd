extends Node

signal item_added(item)
signal item_removed(item)
signal tool_changed(new_tool)

const FOOD_SLOTS = 20
const QUEST_ITEM_SLOTS = 20
const TOOL_SLOTS = 5
const QUICK_FOOD_SLOTS = 4

var character: CharacterBody2D
var tools: Array = []
var food_items: Array = []
var quest_items: Array = []
var quick_food_slots: Array = []

var equipped_tool = null

# Debug variables
var debug_mode: bool = false

func initialize(_character: CharacterBody2D):
    character = _character

func add_item(item):
    var success = false
    match item.type:
        "tool":
            if tools.size() < TOOL_SLOTS:
                tools.append(item)
                success = true
        "food":
            if food_items.size() < FOOD_SLOTS:
                food_items.append(item)
                success = true
        "quest":
            if quest_items.size() < QUEST_ITEM_SLOTS:
                quest_items.append(item)
                success = true
    
    if success:
        emit_signal("item_added", item)
    return success

func remove_item(item):
    var success = false
    match item.type:
        "tool":
            success = tools.erase(item)
            if equipped_tool == item:
                unequip_tool()
        "food":
            success = food_items.erase(item)
            quick_food_slots.erase(item)
        "quest":
            success = quest_items.erase(item)
    
    if success:
        emit_signal("item_removed", item)
    return success

func equip_tool(tool):
    if tool in tools:
        unequip_tool()
        equipped_tool = tool
        emit_signal("tool_changed", equipped_tool)

func unequip_tool():
    if equipped_tool:
        var old_tool = equipped_tool
        equipped_tool = null
        emit_signal("tool_changed", null)
        return old_tool
    return null

func use_equipped_tool():
    if equipped_tool and equipped_tool.has_method("use"):
        equipped_tool.use(character)

func add_to_quick_food(food_item):
    if food_item in food_items and quick_food_slots.size() < QUICK_FOOD_SLOTS:
        quick_food_slots.append(food_item)
        return true
    return false

func remove_from_quick_food(food_item):
    return quick_food_slots.erase(food_item)

func use_quick_food(index: int):
    if index < quick_food_slots.size():
        var food = quick_food_slots[index]
        if food.has_method("use"):
            food.use(character)
            if food.quantity <= 0:
                remove_item(food)
                quick_food_slots.remove(index)

func get_save_data() -> Dictionary:
    return {
        "tools": tools.map(func(tool): return tool.get_save_data()),
        "food_items": food_items.map(func(food): return food.get_save_data()),
        "quest_items": quest_items.map(func(item): return item.get_save_data()),
        "quick_food_slots": quick_food_slots.map(func(food): return food.get_save_data()),
        "equipped_tool": equipped_tool.get_save_data() if equipped_tool else null
    }

func load_save_data(data: Dictionary):
    tools = data["tools"].map(func(tool_data): return create_item_from_save_data(tool_data))
    food_items = data["food_items"].map(func(food_data): return create_item_from_save_data(food_data))
    quest_items = data["quest_items"].map(func(item_data): return create_item_from_save_data(item_data))
    quick_food_slots = data["quick_food_slots"].map(func(food_data): return create_item_from_save_data(food_data))
    if data["equipped_tool"]:
        equipped_tool = create_item_from_save_data(data["equipped_tool"])

func create_item_from_save_data(data: Dictionary):
    # Implement this based on your item creation system
    pass

# Debug functions
func toggle_debug_mode():
    debug_mode = !debug_mode
    print("Inventory debug mode: ", "ON" if debug_mode else "OFF")

func debug_print_inventory():
    print("Inventory Contents:")
    print("Tools:")
    for i, tool in enumerate(tools):
        print(f"  {i + 1}. {tool.name}")
    print(f"Equipped Tool: {equipped_tool.name if equipped_tool else 'None'}")
    print("Food Items:")
    for i, food in enumerate(food_items):
        print(f"  {i + 1}. {food.name}")
    print("Quest Items:")
    for i, item in enumerate(quest_items):
        print(f"  {i + 1}. {item.name}")
    print("Quick Food Slots:")
    for i, food in enumerate(quick_food_slots):
        print(f"  {i + 1}. {food.name}")

func debug_add_test_items():
    # Implement this to add test items of each type
    pass

func debug_clear_inventory():
    tools.clear()
    food_items.clear()
    quest_items.clear()
    quick_food_slots.clear()
    equipped_tool = null
    print("Inventory cleared")

# Add any additional inventory-related methods here
