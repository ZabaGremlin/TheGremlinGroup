extends Control

signal options_changed

@onready var music_slider = $VBoxContainer/MusicSlider
@onready var sfx_slider = $VBoxContainer/SFXSlider
@onready var resolution_option = $VBoxContainer/ResolutionOption
@onready var control_toggle = $VBoxContainer/ControlToggle

var resolutions = [
    Vector2(640, 480),  # 4:3
    Vector2(1280, 720),  # 16:9
    Vector2(1920, 1080)  # 16:9 Full HD
]

func _ready():
    load_settings()
    setup_resolution_options()

func _on_music_slider_value_changed(value):
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)
    save_settings()

func _on_sfx_slider_value_changed(value):
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value)
    save_settings()

func _on_resolution_option_item_selected(index):
    OS.window_size = resolutions[index]
    save_settings()

func _on_control_toggle_toggled(button_pressed):
    InputManager.set_input_mode("gamepad" if button_pressed else "keyboard_mouse")
    save_settings()

func setup_resolution_options():
    resolution_option.clear()
    for res in resolutions:
        resolution_option.add_item(f"{res.x}x{res.y}")

func save_settings():
    var settings = {
        "music_volume": music_slider.value,
        "sfx_volume": sfx_slider.value,
        "resolution_index": resolution_option.selected,
        "use_gamepad": control_toggle.button_pressed
    }
    var file = FileAccess.open("user://settings.save", FileAccess.WRITE)
    file.store_var(settings)
    file.close()
    emit_signal("options_changed")

func load_settings():
    if FileAccess.file_exists("user://settings.save"):
        var file = FileAccess.open("user://settings.save", FileAccess.READ)
        var settings = file.get_var()
        file.close()
        
        music_slider.value = settings.get("music_volume", 0)
        sfx_slider.value = settings.get("sfx_volume", 0)
        resolution_option.select(settings.get("resolution_index", 1))
        control_toggle.button_pressed = settings.get("use_gamepad", false)
        
        OS.window_size = resolutions[resolution_option.selected]
        InputManager.set_input_mode("gamepad" if control_toggle.button_pressed else "keyboard_mouse")

# Debug functions
func debug_print_settings():
    print("Options Menu Settings:")
    print(f"  Music Volume: {music_slider.value}")
    print(f"  SFX Volume: {sfx_slider.value}")
    print(f"  Resolution: {resolutions[resolution_option.selected]}")
    print(f"  Use Gamepad: {control_toggle.button_pressed}")

func debug_reset_to_defaults():
    music_slider.value = 0
    sfx_slider.value = 0
    resolution_option.select(1)  # Default to 1280x720
    control_toggle.button_pressed = false
    save_settings()
    print("Settings reset to defaults")
