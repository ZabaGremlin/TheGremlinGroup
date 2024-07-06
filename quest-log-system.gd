extends Node

signal quest_added(quest)
signal quest_updated(quest)
signal quest_completed(quest)

class Quest:
    var id: String
    var title: String
    var description: String
    var objectives: Array
    var is_completed: bool = false
    var is_main_quest: bool = false

    func _init(_id: String, _title: String, _description: String, _objectives: Array, _is_main_quest: bool = false):
        id = _id
        title = _title
        description = _description
        objectives = _objectives
        is_main_quest = _is_main_quest

    func update_objective(objective_id: String, progress: int):
        for objective in objectives:
            if objective.id == objective_id:
                objective.current_progress = min(progress, objective.required_progress)
                break
        check_completion()

    func check_completion():
        is_completed = objectives.all(func(obj): return obj.current_progress >= obj.required_progress)

class Objective:
    var id: String
    var description: String
    var current_progress: int = 0
    var required_progress: int

    func _init(_id: String, _description: String, _required_progress: int):
        id = _id
        description = _description
        required_progress = _required_progress

var quests: Dictionary = {}

func add_quest(quest: Quest):
    quests[quest.id] = quest
    emit_signal("quest_added", quest)

func get_quest(quest_id: String) -> Quest:
    return quests.get(quest_id)

func update_quest_objective(quest_id: String, objective_id: String, progress: int):
    var quest = get_quest(quest_id)
    if quest:
        quest.update_objective(objective_id, progress)
        emit_signal("quest_updated", quest)
        if quest.is_completed:
            emit_signal("quest_completed", quest)

func get_active_quests() -> Array:
    return quests.values().filter(func(quest): return not quest.is_completed)

func get_completed_quests() -> Array:
    return quests.values().filter(func(quest): return quest.is_completed)

func get_main_quests() -> Array:
    return quests.values().filter(func(quest): return quest.is_main_quest)

func get_side_quests() -> Array:
    return quests.values().filter(func(quest): return not quest.is_main_quest)

# Save/Load functions
func get_save_data() -> Dictionary:
    var save_data = {}
    for quest_id in quests:
        var quest = quests[quest_id]
        save_data[quest_id] = {
            "is_completed": quest.is_completed,
            "objectives": {}
        }
        for objective in quest.objectives:
            save_data[quest_id]["objectives"][objective.id] = objective.current_progress
    return save_data

func load_save_data(data: Dictionary):
    for quest_id in data:
        var quest = get_quest(quest_id)
        if quest:
            quest.is_completed = data[quest_id]["is_completed"]
            for objective_id in data[quest_id]["objectives"]:
                update_quest_objective(quest_id, objective_id, data[quest_id]["objectives"][objective_id])

# Debug functions
func debug_print_quests():
    print("All Quests:")
    for quest in quests.values():
        print(f"- {quest.title} ({'Main' if quest.is_main_quest else 'Side'}, {'Completed' if quest.is_completed else 'Active'})")
        for objective in quest.objectives:
            print(f"  * {objective.description}: {objective.current_progress}/{objective.required_progress}")

func debug_add_test_quest():
    var new_quest = Quest.new(
        "test_quest",
        "Test Quest",
        "This is a test quest",
        [
            Objective.new("obj1", "Complete first objective", 3),
            Objective.new("obj2", "Complete second objective", 1)
        ]
    )
    add_quest(new_quest)
    print("Test quest added")

func debug_complete_test_quest():
    update_quest_objective("test_quest", "obj1", 3)
    update_quest_objective("test_quest", "obj2", 1)
    print("Test quest completed")
