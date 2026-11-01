## Modal help, normal punctuation and live-client continuity via injected input.
extends "res://tests/application_objects.gd"

func run() -> void:
	output_dir = ProjectSettings.globalize_path("res://../.tools/help-overlay-test").simplify_path()
	DirAccess.make_dir_recursive_absolute(output_dir)
	for name in ["before.txt", "after.txt"]:
		var marker := output_dir.path_join(name)
		if FileAccess.file_exists(marker): DirAccess.remove_absolute(marker)
	study = load("res://scenes/main.tscn").instantiate()
	study.get_node("DesktopRuntime").auto_start_terminal = true
	root.add_child(study)
	current_scene = study
	terminal = study.terminal_screen
	app = study.application_mode
	objects = study.application_objects
	var help = study.desktop_runtime.help_overlay
	var player = study.get_node("Player")
	var launcher = study.app_launcher
	var deadline := Time.get_ticks_msec() + 15000
	while objects.bindings.is_empty() and Time.get_ticks_msec() < deadline: await process_frame
	root.grab_focus()
	await settle()
	check(not objects.bindings.is_empty(), "No live terminal")
	if failures:
		await study.desktop_runtime.shutdown()
		quit(1)
		return
	check(app.panel.find_children("*", "Label", true, false).is_empty(), "Application help text still exists outside overlay")
	check(objects.find_children("*", "CanvasLayer", true, false).is_empty(), "World object instructions still exist")
	await capture("world-clean.png")
	# Hold walking and a panel grab before opening: help must cancel safely.
	var handle: int = terminal.handle
	var object: Node3D = objects.bindings[handle]
	var original := object.global_transform
	await mouse(point(handle), true)
	await motion(point(handle) + Vector2(50, 0))
	await key(KEY_W, true)
	await tap(KEY_F1)
	check(help.opened and not objects.has_grab() and object.global_transform.is_equal_approx(original), "Help did not cancel a held panel")
	check(player._held.is_empty() and player.application_mode and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "Help retains movement/capture")
	var stopped: Vector3 = player.position
	await key(KEY_W, false)
	await mouse(point(handle), false)
	await tap(KEY_W)
	await tap(KEY_D)
	await settle()
	check(player.position.distance_to(stopped) < 0.01, "World input escaped help")
	await capture("world-help.png")
	await tap(KEY_F11)
	await settle()
	check(help.opened and root.mode == Window.MODE_FULLSCREEN, "Help swallowed fullscreen shortcut")
	await tap(KEY_F11)
	await settle()
	await key(KEY_F1, true, true)
	check(help.opened, "Key repeat closed help")
	await tap(KEY_ESCAPE)
	check(not help.opened and not player.application_mode, "Escape did not restore world")
	await chord(KEY_SHIFT, KEY_SLASH)
	check(not help.opened, "Question mark opens help")
	launcher.open()
	launcher.show_search()
	launcher.query.text = "term"
	await tap(KEY_F1)
	await tap(KEY_X)
	await tap(KEY_F1)
	check(launcher.opened and launcher.query.has_focus() and launcher.query.text == "term", "Help altered launcher search/focus")
	launcher.close()
	check(app.enter_application(), "Application entry failed")
	await settle()
	await type_text("printf '?BEFORE?\\n' > '" + output_dir.path_join("before.txt") + "'\n")
	check(await wait_file("before.txt") == "?BEFORE?\n", "Question-mark typing failed")
	await capture("application-clean.png")
	await tap(KEY_F1)
	check(help.opened and app.active and terminal.session.keyboard_focus_handle() == 0, "Help did not suspend client keyboard focus")
	await type_text("BADINPUT")
	await mouse(app.view.get_global_rect().get_center(), true)
	check(not terminal.session.pointer_grabbed(), "Help forwarded a pointer grab")
	await mouse(app.view.get_global_rect().get_center(), false)
	await capture("application-help.png")
	root.size = Vector2i(640, 480)
	await settle()
	check(help.grid.columns == 1 and help.panel.size.x <= 600 and help.panel.size.y <= 440, "Help does not fit a small window")
	await capture("small-help-top.png")
	help.scroll.scroll_vertical = 10000
	await settle()
	check(help.scroll.scroll_vertical > 0, "Help cannot scroll to all commands")
	await capture("small-help-bottom.png")
	root.size = Vector2i(1280, 800)
	await settle()
	# A button click must dismiss without sending the click into the live app.
	await click_at(help.close_button.get_global_rect().get_center())
	check(not help.opened and app.active and terminal.session.keyboard_focus_handle() == handle, "Close did not restore client focus")
	await type_text("printf '?AFTER?\\n' > '" + output_dir.path_join("after.txt") + "'\n")
	check(await wait_file("after.txt") == "?AFTER?\n", "Help leaked keys or broke resumed typing")
	await capture("application-resumed.png")
	await tap(KEY_F1)
	root.propagate_notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(not help.opened and not app.active and not player.application_mode, "Focus loss left a modal or input lock")
	root.propagate_notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN)
	check(app.enter_application(), "Cannot re-enter after focus loss")
	await settle()
	await type_text("sleep 0.5; exit\n")
	await tap(KEY_F1)
	await create_timer(1.5).timeout
	check(help.opened and not app.active and player.application_mode, "Client close beneath help lost modal ownership")
	await tap(KEY_F1)
	check(not help.opened and not player.application_mode, "Closed client left stale help focus")
	await study.desktop_runtime.shutdown()
	print("HELP_OVERLAY_OK failures=", failures)
	quit(1 if failures else 0)
