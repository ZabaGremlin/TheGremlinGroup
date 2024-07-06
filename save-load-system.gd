extends Node

const SAVE_DIR = "user://saves/"
const SAVE_FILE_EXTENSION = ".save"
const MAX_SAVE_SLOTS = 3

func _ready():
    create_save_directory()

func create_save_directory():
    var dir = DirAccess.open("user://")
    if !dir.dir_exists(SAVE_DIR):
        dir.make_dir(SAVE_DIR)

func save_game(save_data: Dictionary, slot: int = -1):
    if slot == -1:
        slot = find_empty_slot()
    
    if slot == -1:
        print("No empty save slots available")
        return false
    
    save_data["timestamp"] = Time.get_unix_time_from_system()
    
    var file = FileAccess.open(SAVE_DIR + "save_" + str(slot) + SAVE_FILE_EXTENSION, FileAccess.WRITE)
    if file:
        file.store_var(save_data)
        file.close()
        print("Game saved successfully in slot ", slot)
        return true
    else:
        print("Error saving game")
        return false

func load_game(slot: int) -> Dictionary:
    var file = FileAccess.open(SAVE_DIR + "save_" + str(slot) + SAVE_FILE_EXTENSION, FileAccess.READ)
    if file:
        var save_data = file.get_var()
        file.close()
        print("Game loaded successfully from slot ", slot)
        return save_data
    else:
        print("Error loading game or no save file found")
        return {}

func load_latest_game() -> Dictionary:
    var latest_slot = find_latest_save()
    if latest_slot != -1:
        return load_game(latest_slot)
    return {}

func find_empty_slot() -> int:
    for i in range(MAX_SAVE_SLOTS):
        if !FileAccess.file_exists(SAVE_DIR + "save_" + str(i) + SAVE_FILE_EXTENSION):
            return i
    return -1

func find_latest_save() -> int:
    var latest_time = 0
    var latest_slot = -1
    for i in range(MAX_SAVE_SLOTS):
        var file_path = SAVE_DIR + "save_" + str(i) + SAVE_FILE_EXTENSION
        if FileAccess.file_exists(file_path):
            var file = FileAccess.open(file_path, FileAccess.READ)
            if file:
                var save_data = file.get_var()
                file.close()
                if save_data.has("timestamp") and save_data["timestamp"] > latest_time:
                    latest_time = save_data["timestamp"]
                    latest_slot = i
    return latest_slot

func get_save_slots_info() -> Array:
    var slots_info = []
    for i in range(MAX_SAVE_SLOTS):
        var file_path = SAVE_DIR + "save_" + str(i) + SAVE_FILE_EXTENSION
        if FileAccess.file_exists(file_path):
            var file = FileAccess.open(file_path, FileAccess.READ)
            if file:
                var save_data = file.get_var()
                file.close()
                slots_info.append({
                    "slot": i,
                    "timestamp": save_data["timestamp"],
                    "level": save_data["current_level"]
                })
        else:
            slots_info.append({"slot": i, "empty": true})
    return slots_info

# Debug functions
func debug_print_save_slots():
    var slots_info = get_save_slots_info()
    print("Save Slots Information:")
    for slot in slots_info:
        if slot.has("empty"):
            print(f"Slot {slot.slot}: Empty")
        else:
            var datetime = Time.get_datetime_string_from_unix_time(slot.timestamp)
            print(f"Slot {slot.slot}: Level {slot.level}, Saved on {datetime}")

func debug_clear_all_saves():
    var dir = DirAccess.open(SAVE_DIR)
    var files = dir.get_files()
    for file in files:
        if file.ends_with(SAVE_FILE_EXTENSION):
            dir.remove(file)
    print("All save files cleared")

# Add any additional save/load related methods here
