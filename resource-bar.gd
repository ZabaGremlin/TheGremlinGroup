extends Control

enum ResourceType { HEALTH, WATER }

signal value_changed(new_value, max_value)

@export var resource_type: ResourceType
@export var gradient: Gradient

@onready var progress_bar = $ProgressBar
@onready var label = $Label

var current_value: float = 100
var max_value: float = 100

# Debug variables
var debug_mode: bool = false

func _ready():
    update_bar()

func set_value(value: float):
    current_value = clamp(value, 0, max_value)
    update_bar()
    emit_signal("value_changed", current_value, max_value)

func set_max_value(value: float):
    max_value = max(value, 0)
    current_value = min(current_value, max_value)
    update_bar()
    emit_signal("value_changed", current_value, max_value)

func update_bar():
    var percentage = current_value / max_value
    progress_bar.value = percentage * 100
    label.text = "%d / %d" % [current_value, max_value]
    
    if gradient:
        progress_bar.modulate = gradient.sample(percentage)
    
    if debug_mode:
        print(f"Resource Bar updated: {current_value}/{max_value}")

# Connect this to the appropriate system's signal
func _on_resource_changed(new_value, new_max_value):
    set_max_value(new_max_value)
    set_value(new_value)

# Debug functions
func toggle_debug_mode():
    debug_mode = !debug_mode
    print("Resource Bar debug mode: ", "ON" if debug_mode else "OFF")

func debug_set_value(value: float):
    set_value(value)
    print(f"Resource value set to: {value}")

func debug_set_max_value(value: float):
    set_max_value(value)
    print(f"Resource max value set to: {value}")

func debug_print_info():
    print("Resource Bar Info:")
    print(f"  Type: {ResourceType.keys()[resource_type]}")
    print(f"  Current Value: {current_value}")
    print(f"  Max Value: {max_value}")
    print(f"  Percentage: {(current_value / max_value) * 100}%")

# Add any additional resource bar-related methods here
