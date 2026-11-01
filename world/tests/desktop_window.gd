## Actual host modes and real-terminal continuity; injected shortcut events.
extends "res://tests/application_objects.gd"

class InputProbe extends Node:
	var seen: Array[int] = []
	func _input(event: InputEvent) -> void:
		if event is InputEventKey:
			seen.append(event.physical_keycode if event.physical_keycode else event.keycode)

var quit_session: Object
var quit_pid := -1
var quit_socket := ""
var quit_expected := false
var quit_requests := 0

func _finalize() -> void:
	if not quit_expected: return
	check(quit_requests == 1, "Quit shortcut was not routed once")
	check(quit_session != null and not quit_session.is_running(), "Quit left compositor running")
	check(not OS.is_process_running(quit_pid), "Quit left owned terminal running")
	check(not DirAccess.dir_exists_absolute(quit_socket), "Quit leaked its socket directory")
	print("DESKTOP_WINDOW_OK failures=", failures)

func run() -> void:
	output_dir = ProjectSettings.globalize_path("res://../.tools/desktop-window-test")
	DirAccess.make_dir_recursive_absolute(output_dir)
	var marker := output_dir.path_join("typed.txt")
	if FileAccess.file_exists(marker): DirAccess.remove_absolute(marker)
	study = load("res://scenes/main.tscn").instantiate()
	study.get_node("DesktopRuntime").auto_start_terminal = true
	root.add_child(study)
	current_scene = study
	terminal = study.terminal_screen
	app = study.application_mode
	objects = study.application_objects
	var desktop = study.desktop_runtime
	var controls = desktop.window_controls
	var probe := InputProbe.new()
	desktop.add_child(probe)
	desktop.move_child(probe, controls.get_index())
	var deadline := Time.get_ticks_msec() + 15000
	while objects.bindings.is_empty() and Time.get_ticks_msec() < deadline: await process_frame
	root.grab_focus()
	await settle()
	var start_windowed := "--windowed" in OS.get_cmdline_user_args()
	print("DESKTOP_WINDOW_START mode=", root.mode, " native_mode=", DisplayServer.window_get_mode(), " size=", root.size, " expected_windowed=", start_windowed)
	check(root.mode == (Window.MODE_WINDOWED if start_windowed else Window.MODE_FULLSCREEN), "Startup mode/override incorrect")
	check(not objects.bindings.is_empty(), "Missing real terminal")
	if failures:
		await desktop.shutdown()
		quit(1)
		return
	await capture("startup-windowed.png" if start_windowed else "startup-fullscreen.png")
	if not start_windowed:
		await tap(KEY_F11)
		await settle()
	check(root.mode == Window.MODE_WINDOWED, "F11 did not exit fullscreen")
	check(root.size == Vector2i(1280, 800), "Initial window size not restored")
	root.size = Vector2i(1000, 700)
	await settle()
	await key(KEY_F11, true)
	await settle()
	check(root.mode == Window.MODE_FULLSCREEN, "F11 did not enter fullscreen")
	await key(KEY_F11, true, true)
	check(root.mode == Window.MODE_FULLSCREEN, "Key repeat toggled fullscreen")
	await key(KEY_SHIFT, true)
	await key(KEY_F11, false)
	await key(KEY_SHIFT, false)
	check(not probe.seen.has(KEY_F11), "Reserved F11 press/release reached client routing")
	await chord(KEY_SHIFT, KEY_F11)
	check(probe.seen.has(KEY_F11) and root.mode == Window.MODE_FULLSCREEN, "Modified F11 was stolen")
	await tap(KEY_F11)
	await settle()
	check(root.mode == Window.MODE_WINDOWED and root.size == Vector2i(1000, 700), "Toggle lost resized window dimensions")
	await capture("restored-window.png")
	var launcher = study.app_launcher
	launcher.open()
	launcher.show_search()
	await tap(KEY_F11)
	await settle()
	check(launcher.opened and launcher.query.has_focus() and root.mode == Window.MODE_FULLSCREEN, "Launcher consumed fullscreen shortcut or lost search focus")
	launcher.close()
	check(app.enter_application(), "Application entry failed")
	await settle()
	var handle: int = terminal.handle
	var entity: String = objects.bindings[handle].entity_id
	await tap(KEY_F11)
	await create_timer(0.6).timeout
	check(app.active and root.mode == Window.MODE_WINDOWED, "Application consumed fullscreen shortcut or lost focus")
	await type_text("printf 'WINDOW_OK\\n' > '" + output_dir.path_join("typed.txt") + "'\n")
	check(await wait_file("typed.txt") == "WINDOW_OK\n", "Terminal typing failed after fullscreen resize")
	await tap(KEY_F11)
	await create_timer(0.6).timeout
	check(app.active and root.mode == Window.MODE_FULLSCREEN and terminal.handle == handle and objects.bindings[handle].entity_id == entity, "Fullscreen lost live application identity/focus")
	await capture("fullscreen-application.png")
	# Verify the real close path, including child process/socket cleanup in finalize.
	if start_windowed:
		await return_to_room()
		launcher.open()
		launcher.show_search()
	quit_session = terminal.session
	quit_pid = terminal.child_pid
	quit_socket = quit_session.socket_path().get_base_dir()
	controls.quit_requested.connect(func(): quit_requests += 1)
	quit_expected = true
	print("DESKTOP_WINDOW_QUIT mode=", "launcher" if start_windowed else "application")
	await chord(KEY_ALT, KEY_F4)
	await create_timer(5).timeout
	check(false, "Alt+F4 did not quit")
	quit(1)
