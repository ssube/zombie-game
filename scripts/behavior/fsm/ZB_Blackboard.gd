@icon("res://textures/icons/fsm_blackboard.svg")
extends Node
class_name ZB_Blackboard

signal field_added(key: StringName, value: Variant)
signal field_changed(key: StringName, old_value: Variant, new_value: Variant)
signal field_removed(key: StringName, old_value: Variant)

@export var data: Dictionary[StringName, Variant] = {}


# ----------------------------------------------------
# SET / GET
# ----------------------------------------------------

func set_value(key: StringName, value: Variant) -> void:
    if not data.has(key):
        data[key] = value
        field_added.emit(key, value)
        return

    var old = data[key]

    # If unchanged, do nothing
    if old == value:
        return

    data[key] = value
    field_changed.emit(key, old, value)


func get_value(key: StringName, default: Variant = null) -> Variant:
    return data.get(key, default)


# ----------------------------------------------------
# REMOVE / CLEAR
# ----------------------------------------------------

func remove_value(key: StringName) -> void:
    if not data.has(key):
        return

    var old = data[key]
    data.erase(key)
    field_removed.emit(key, old)


func clear() -> void:
    for key in data.keys():
        field_removed.emit(key, data[key])
    data.clear()


# ----------------------------------------------------
# BOOLEAN HELPERS
# ----------------------------------------------------

func has(key: StringName) -> bool:
    return data.has(key)


func keys() -> Array:
    return data.keys()


func dump() -> Dictionary:
    # returns a copy for debugging
    return data.duplicate(true)
