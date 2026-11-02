## Real installed terminal launch/resize parity; injected events, not human input.
extends "res://tests/application_transition.gd"

func check_size(desktop_id: String) -> void:
	await create_timer(0.6).timeout
	var state: Dictionary = terminal.session.window_state(terminal.handle)
	var wanted := Vector2(root.size - Vector2i(64, 64)).min(Vector2(2048, 2048))
	print("TERMINAL_STATE ", desktop_id, " host=", root.size, " view=", app.view.size, " state=", state)
	check(app.active and not app.resize_pending and state.committed_serial == state.sent_serial, "Resize/focus did not settle: " + desktop_id)
	check(app.view.size.x >= wanted.x - 100 and app.view.size.y >= wanted.y - 100, "Terminal did not fill application view: " + desktop_id)
	check(objects.bindings[terminal.handle].presentation_hidden, "Focused terminal also visible in world: " + desktop_id)

func run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Terminal compatibility requires a graphical display and installed Ghostty/Alacritty")
		quit(1)
		return
	output_dir = ProjectSettings.globalize_path("res://../.tools/terminal-compatibility-test")
	DirAccess.make_dir_recursive_absolute(output_dir)
	study = load("res://scenes/main.tscn").instantiate()
	root.add_child(study)
	current_scene = study
	terminal = study.terminal_screen
	app = study.application_mode
	objects = study.application_objects
	var launcher = study.app_launcher
	var deadline := Time.get_ticks_msec() + 15000
	while launcher.entries.is_empty() and Time.get_ticks_msec() < deadline: await process_frame
	root.grab_focus()
	await settle()
	var initial_mode := root.mode
	var initial_size := root.size
	for desktop_id in ["Alacritty.desktop", "com.mitchellh.ghostty.desktop"]:
		launcher.open()
		launcher.launch(desktop_id)
		deadline = Time.get_ticks_msec() + 15000
		while not launcher.pending.is_empty() and Time.get_ticks_msec() < deadline: await process_frame
		check(app.active, "Launch failed: " + desktop_id + " " + launcher.notice.text)
		if not app.active: break
		await create_timer(2.0).timeout
		await check_size(desktop_id)
		await chord(KEY_CTRL, KEY_L)
		await type_text("printf 'ELSEWHERE TERMINAL VIEW\\n'\n")
		await capture(desktop_id + ".png")
		var window: int = terminal.handle
		var object: Node3D = objects.bindings[window]
		var identity: String = object.entity_id
		var placement: Transform3D = object.global_transform
		var marker: String = desktop_id + "-state.txt"
		var path := output_dir.path_join(marker)
		if FileAccess.file_exists(path): DirAccess.remove_absolute(path)
		await type_text("elsewhere_probe=retained\n")
		await return_to_room()
		check(not object.presentation_hidden and object.screen.visible, "World return did not restore panel")
		await capture(desktop_id + "-world.png")
		check(app.enter_application(), "Could not revisit terminal")
		await finish_flight()
		check(objects.bindings[window] == object and object.entity_id == identity and object.global_transform.is_equal_approx(placement), "Revisit changed terminal entity/placement")
		await type_text("printf '%s' \"$elsewhere_probe\" > '" + path + "'\n")
		check(await wait_file(marker) == "retained", "Revisit lost shell state or typing")
		root.mode = Window.MODE_WINDOWED
		var grids: Array[String] = []
		for size in [Vector2i(1000, 700), Vector2i(1600, 900)]:
			root.size = size
			await check_size(desktop_id)
			marker = desktop_id + "-%d.txt" % size.x
			path = output_dir.path_join(marker)
			if FileAccess.file_exists(path): DirAccess.remove_absolute(path)
			await type_text("stty size > '" + path + "'\n")
			grids.append(await wait_file(marker))
			await capture(desktop_id + "-%d.png" % size.x)
		check(grids[0] != grids[1], "Terminal grid did not reflow on host resize")
		root.size = initial_size
		root.mode = initial_mode
		await check_size(desktop_id)
		await type_text("exit\n")
		deadline = Time.get_ticks_msec() + 5000
		while app.active and Time.get_ticks_msec() < deadline: await process_frame
		check(not app.active, "Terminal did not close: " + desktop_id)
	await terminal.shutdown()
	print("TERMINAL_COMPATIBILITY_OK failures=", failures)
	quit(1 if failures else 0)
