## Reserved host-window shortcuts, ahead of launcher and client input routing.
extends Node

signal quit_requested

var _windowed_size := Vector2i.ZERO
var _consumed_keys: Dictionary = {}

func _ready() -> void:
	_windowed_size = Vector2i(
		ProjectSettings.get_setting("display/window/size/viewport_width", 1280),
		ProjectSettings.get_setting("display/window/size/viewport_height", 800))
	# The pinned engine's native --windowed does not override a fullscreen
	# project setting. Keep an explicit user-argument path for nested development.
	if "--windowed" in OS.get_cmdline_user_args() and DisplayServer.get_name() != "headless":
		get_window().mode = Window.MODE_WINDOWED
		get_window().size = _windowed_size

func toggle_fullscreen() -> void:
	if DisplayServer.get_name() == "headless": return
	var window := get_window()
	if window.mode in [Window.MODE_FULLSCREEN, Window.MODE_EXCLUSIVE_FULLSCREEN]:
		window.mode = Window.MODE_WINDOWED
		window.size = _windowed_size
	else:
		_windowed_size = window.size
		window.mode = Window.MODE_FULLSCREEN

func _input(event: InputEvent) -> void:
	if not event is InputEventKey: return
	var key: int = event.physical_keycode if event.physical_keycode else event.keycode
	if not event.pressed:
		# Match the press even if the modifier was released first.
		if _consumed_keys.erase(key): get_viewport().set_input_as_handled()
		return
	var fullscreen: bool = key == KEY_F11 and not (event.alt_pressed or event.ctrl_pressed or event.shift_pressed or event.meta_pressed)
	var quit: bool = key == KEY_F4 and event.alt_pressed and not (event.ctrl_pressed or event.shift_pressed or event.meta_pressed)
	if not (fullscreen or quit or _consumed_keys.has(key)): return
	get_viewport().set_input_as_handled()
	if event.echo or _consumed_keys.has(key): return
	_consumed_keys[key] = true
	if fullscreen: toggle_fullscreen()
	elif quit: quit_requested.emit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_consumed_keys.clear()
