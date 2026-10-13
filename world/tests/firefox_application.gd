## Real Firefox launch beside the host browser; local HTML is test content only.
extends "res://tests/chrome_application.gd"

func finish() -> void:
	await terminal.shutdown()
	if fixture_pid > 0 and OS.is_process_running(fixture_pid): OS.kill(fixture_pid)
	fixture_pid = -1
	print("FIREFOX_APPLICATION_OK failures=", failures)
	quit(1 if failures else 0)

func run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Firefox acceptance requires a graphical renderer")
		quit(1)
		return
	output_dir = ProjectSettings.globalize_path("res://../.tools/firefox-application-test").simplify_path()
	DirAccess.make_dir_recursive_absolute(output_dir)
	for name in ["port.txt", "page.json"]:
		if FileAccess.file_exists(output_dir.path_join(name)): DirAccess.remove_absolute(output_dir.path_join(name))
	OS.set_environment("ELSEWHERE_BROWSER_PROFILE_DIR", output_dir.path_join("profiles"))
	fixture_pid = OS.create_process("/usr/bin/python3", PackedStringArray([ProjectSettings.globalize_path("res://../tests/browser_fixture.py"), output_dir]))
	var port := (await wait_file("port.txt")).strip_edges()
	# Test-only homepage avoids injecting keys into Firefox's first-run splash.
	var profile := output_dir.path_join("profiles/firefox")
	DirAccess.make_dir_recursive_absolute(profile)
	FileAccess.open(profile.path_join("user.js"), FileAccess.WRITE).store_string(
		'user_pref("browser.aboutwelcome.enabled", false);\n' +
		'user_pref("browser.startup.page", 1);\n' +
		'user_pref("browser.startup.homepage", "http://127.0.0.1:' + port + '/");\n' +
		'user_pref("browser.shell.checkDefaultBrowser", false);\n')
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
	check(not launcher.entry("firefox.desktop").is_empty(), "Installed Firefox desktop entry required")
	if failures:
		await finish()
		return
	var first := await browser_launch(launcher, "firefox.desktop")
	await capture("first-launch.png")
	if failures:
		await finish()
		return
	check(launcher.live_windows.get(first) == "firefox.desktop", "Firefox window was not associated with its launcher entry")
	await wait_page("ready", true)
	await type_text("Elsewhere Firefox 42!")
	await wait_page("value", "Elsewhere Firefox 42!")
	check(page_state().get("trusted", false), "Firefox typing did not produce trusted input")
	await chord(KEY_CTRL, KEY_A)
	await chord(KEY_CTRL, KEY_C)
	await tap(KEY_END)
	await chord(KEY_CTRL, KEY_V)
	await wait_page("value", "Elsewhere Firefox 42!Elsewhere Firefox 42!")
	await capture("firefox-input.png")
	await return_to_room()
	check(not app.active and objects.bindings.has(first), "World return lost Firefox")
	var identity: String = objects.bindings[first].entity_id
	var process_count: int = terminal.launched_children.size()
	await capture("firefox-in-world.png")
	var reused := await browser_launch(launcher, "firefox.desktop")
	check(reused == first and objects.bindings[first].entity_id == identity and terminal.launched_children.size() == process_count, "Repeat launch replaced Firefox or started a profile contender")
	await type_text(" returned")
	await wait_page("value", "Elsewhere Firefox 42!Elsewhere Firefox 42! returned")
	await capture("firefox-reused.png")
	var pixels: Image = terminal.last_image
	var target := Vector2(-1,-1)
	for y in range(0,pixels.get_height(),4):
		for x in range(0,pixels.get_width(),4):
			var color := pixels.get_pixel(x,y)
			if absi(color.r8-20)<2 and absi(color.g8-120)<2 and absi(color.b8-200)<2:
				target = Vector2(x+8,y+8)
				break
		if target.x >= 0: break
	check(target.x >= 0, "Firefox test button not rendered")
	if target.x >= 0:
		var position: Vector2 = app.image_rect().position + target / Vector2(pixels.get_size()) * app.image_rect().size
		await motion(position)
		await mouse(position,true)
		await mouse(position,false)
		await wait_page("clicks",1)
		check(page_state().get("trusted",false), "Firefox click was not trusted input")
		await capture("firefox-pointer.png")
	# Additional windows are created by the existing browser, sharing its profile.
	await chord(KEY_CTRL, KEY_N)
	deadline = Time.get_ticks_msec() + 8000
	while objects.bindings.size() < 2 and Time.get_ticks_msec() < deadline: await process_frame
	check(objects.bindings.size() == 2, "Firefox Ctrl+N did not create an independent panel")
	var second: int = 0
	for handle in objects.bindings:
		if handle != first: second = handle
	# Close the original. The remaining browser-created window must not cause
	# a second process/profile lock when the launcher has no mapped launch handle.
	await key(KEY_CTRL, true)
	await key(KEY_SHIFT, true)
	await tap(KEY_W)
	await key(KEY_SHIFT, false)
	await key(KEY_CTRL, false)
	deadline = Time.get_ticks_msec() + 5000
	while objects.bindings.has(first) and Time.get_ticks_msec() < deadline: await process_frame
	check(not objects.bindings.has(first) and objects.bindings.has(second), "Firefox close affected the wrong window")
	launcher.open()
	launcher.launch("firefox.desktop")
	check(launcher.pending.is_empty() and terminal.launched_children.size() == process_count and "already open" in launcher.notice.text, "Untracked browser window allowed another profile contender")
	launcher.close()
	launcher._activate(second)
	await wait_page("ready", true)
	await type_text("Second window")
	await wait_page("value", "Second window")
	await key(KEY_CTRL, true)
	await key(KEY_SHIFT, true)
	await tap(KEY_W)
	await key(KEY_SHIFT, false)
	await key(KEY_CTRL, false)
	# Firefox asks before quitting the last window. Click its real confirmation
	# through the input mapper, leaving the browser's safety preference enabled.
	await settle()
	await capture("firefox-quit-confirmation.png")
	pixels = terminal.last_image
	target = Vector2(-1,-1)
	for y in range(pixels.get_height()/5, pixels.get_height()/2, 2):
		for x in range(pixels.get_width()/2, pixels.get_width()*3/4, 2):
			var color := pixels.get_pixel(x,y)
			if absi(color.r8-184)<5 and absi(color.g8-156)<5 and color.b8 > 250 and pixels.get_pixel(x+16,y+8).is_equal_approx(color):
				target = Vector2(x+16,y+8)
				break
		if target.x >= 0: break
	check(target.x >= 0, "Firefox quit confirmation button not rendered")
	if target.x >= 0:
		var position: Vector2 = app.image_rect().position + target / Vector2(pixels.get_size()) * app.image_rect().size
		await motion(position)
		await mouse(position,true)
		await mouse(position,false)
	deadline = Time.get_ticks_msec() + 8000
	while (not objects.bindings.is_empty() or not terminal.launched_children.is_empty()) and Time.get_ticks_msec() < deadline: await process_frame
	print("FIREFOX_CLOSE windows=",objects.bindings.size()," owned_children=",terminal.launched_children)
	check(objects.bindings.is_empty() and terminal.launched_children.is_empty(), "Firefox-owned close did not release windows/process")
	if failures:
		await capture("close-failure.png")
		await finish()
		return
	DirAccess.remove_absolute(output_dir.path_join("page.json"))
	var relaunched := await browser_launch(launcher, "firefox.desktop")
	check(relaunched != first and objects.bindings.has(relaunched), "Firefox could not relaunch after releasing its profile")
	await wait_page("ready", true)
	await type_text("Reopened Firefox")
	await wait_page("value", "Reopened Firefox")
	await capture("firefox-relaunched.png")
	await finish()
