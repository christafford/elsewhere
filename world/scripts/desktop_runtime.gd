## World-neutral composition and lifetime of the existing desktop services.
extends Node

@export var auto_start_terminal := true

var terminal_screen: Node
var application_mode: CanvasLayer
var app_launcher: CanvasLayer
var application_objects: Node3D
var window_controls: Node
var closing := false

# The location supplies presentation nodes and its placement policy; desktop
# services never look up a desk, room, or other physical scene path.
func initialize(player: CharacterBody3D, screen: MeshInstance3D, status: Label3D, placement_bounds: Callable) -> void:
	assert(terminal_screen == null, "Desktop runtime already initialized")
	assert(is_inside_tree() and player.is_inside_tree(), "Desktop requires a ready scene/player")
	assert(placement_bounds.is_valid(), "Desktop requires a world placement policy")
	terminal_screen = preload("res://scripts/terminal_screen.gd").new()
	terminal_screen.name = "TerminalScreen"
	terminal_screen.screen = screen
	terminal_screen.status = status
	terminal_screen.auto_start_terminal = auto_start_terminal
	add_child(terminal_screen)
	application_mode = preload("res://scripts/application_mode.gd").new()
	application_mode.terminal = terminal_screen
	application_mode.player = player
	add_child(application_mode)
	app_launcher = preload("res://scripts/app_launcher.gd").new()
	app_launcher.terminal = terminal_screen
	app_launcher.app = application_mode
	app_launcher.player = player
	add_child(app_launcher)
	get_tree().auto_accept_quit = false
	var ui := CanvasLayer.new()
	var help := Label.new()
	help.text = "WASD move   •   Hold right mouse to look   •   Shift faster   •   Ctrl / M slow\nEnter use application   •   Ctrl+Alt+Esc return   •   Tab applications   •   Home reset view"
	help.position = Vector2(22, 20)
	help.add_theme_font_size_override("font_size", 16)
	help.add_theme_color_override("font_shadow_color", Color.BLACK)
	help.add_theme_constant_override("shadow_offset_x", 1)
	help.add_theme_constant_override("shadow_offset_y", 2)
	ui.add_child(help)
	var window_help := help.duplicate() as Label
	window_help.text = "F11 fullscreen / window   •   Alt+F4 quit Elsewhere"
	ui.add_child(window_help)
	window_help.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	window_help.position = Vector2(22, -32)
	add_child(ui)
	app_launcher.world_hud = ui
	application_objects = preload("res://scripts/application_objects.gd").new()
	application_objects.terminal = terminal_screen
	application_objects.app = application_mode
	application_objects.launcher = app_launcher
	application_objects.player = player
	application_objects.placement_bounds = placement_bounds
	add_child(application_objects)
	var transition := preload("res://scripts/application_transition.gd").new()
	transition.app = application_mode
	transition.objects = application_objects
	application_mode.transition = transition
	add_child(transition)
	# Input traverses children in reverse order. Reserve host shortcuts before
	# the launcher and application keyboard forwarding can consume them.
	window_controls = preload("res://scripts/desktop_window.gd").new()
	window_controls.name = "DesktopWindow"
	window_controls.quit_requested.connect(request_quit)
	add_child(window_controls)

func shutdown() -> void:
	if terminal_screen != null:
		await terminal_screen.shutdown()

func request_quit() -> void:
	if closing: return
	closing = true
	await shutdown()
	get_tree().quit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		request_quit()
