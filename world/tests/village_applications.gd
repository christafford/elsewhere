## Real outdoor Terminal + Vim session; agent-injected input, not human acceptance.
extends "res://tests/application_objects.gd"

func launch_from_search(identifier: String, query: String) -> int:
	var launcher = study.app_launcher
	await tap(KEY_TAB)
	check(launcher.opened, "World Tab did not open Applications")
	await click_at(launcher.wheel.global_position + launcher.wheel.size * 0.5)
	await search_text(query)
	var found := -1
	for index in range(launcher.results.item_count):
		if launcher.results.get_item_metadata(index) == identifier: found = index
	check(found >= 0, "Installed application missing from search: " + identifier)
	if found < 0: return 0
	launcher.results.select(found)
	await capture("search-" + query.to_lower() + ".png")
	await tap(KEY_ENTER)
	var deadline := Time.get_ticks_msec() + 15000
	while not launcher.pending.is_empty() and Time.get_ticks_msec() < deadline: await process_frame
	await settle()
	check(app.active and objects.bindings.has(terminal.handle), "Search launch did not present: " + launcher.notice.text)
	check(launcher.live_windows.get(terminal.handle) == identifier, "Search selected the wrong application")
	return terminal.handle

func frames(count: int) -> void:
	for frame in range(count): await physics_frame

func finish() -> void:
	await study.desktop_runtime.shutdown()
	check(terminal.launched_children.is_empty() and not terminal.child_running(), "Owned applications survived shutdown")
	print("VILLAGE_APPLICATIONS_OK clients=2 failures=", failures)
	quit(1 if failures else 0)

func run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Village application acceptance requires graphical rendering")
		quit(1)
		return
	output_dir = ProjectSettings.globalize_path("res://../.tools/village-applications-test").simplify_path()
	DirAccess.make_dir_recursive_absolute(output_dir)
	for name in ["before.txt", "after.txt", "editor.txt"]:
		if FileAccess.file_exists(output_dir.path_join(name)): DirAccess.remove_absolute(output_dir.path_join(name))
	study = load(ProjectSettings.get_setting("application/run/main_scene")).instantiate()
	root.add_child(study)
	current_scene = study
	terminal = study.terminal_screen
	app = study.application_mode
	objects = study.application_objects
	var player = study.get_node("Player")
	var launcher = study.app_launcher
	var deadline := Time.get_ticks_msec() + 15000
	while launcher.entries.is_empty() and Time.get_ticks_msec() < deadline: await process_frame
	root.grab_focus()
	await settle()
	check(study.name == "Outdoor" and root.has_focus() and app.host_focused, "Default outdoor scene/host focus unavailable")
	check(terminal.session != null and terminal.session.is_running() and objects.bindings.is_empty(), "Expected healthy empty desktop")
	if failures:
		await finish()
		return
	var first := await launch_from_search(launcher.TERMINAL_ID, "Terminal")
	if failures:
		await finish()
		return
	var first_object: Node3D = objects.bindings[first]
	var first_id: String = first_object.entity_id
	await type_text("VILLAGE_SESSION=still-here; printf '%s:%s\\n' \"$$\" \"$VILLAGE_SESSION\" > '" + output_dir.path_join("before.txt") + "'\n")
	var before := await wait_file("before.txt")
	check(before.ends_with(":still-here\n"), "Initial shell state was not set")
	await type_text("while true; do printf 'LIVE VILLAGE '; date +%T; sleep 0.5; done\n")
	await return_to_room()
	var second := await launch_from_search("vim.desktop", "Vim")
	if failures:
		await finish()
		return
	var second_object: Node3D = objects.bindings[second]
	var second_id: String = second_object.entity_id
	await type_text("iUNSAVED VILLAGE EDITOR\n")
	await capture("editor-before-walk.png")
	await return_to_room()
	check(objects.bindings.size() == 2 and first != second and first_id != second_id, "Real applications do not have independent bindings and identities")
	check(first_object.texture != second_object.texture, "Applications share client pixels")
	var other_transform: Transform3D = second_object.global_transform
	var original: Transform3D = first_object.global_transform
	await capture("two-live-applications.png")
	# Commit an actual drag and rotation; no fixture transform assignment.
	var pointer := point(first)
	await mouse(pointer, true)
	await motion(pointer + Vector2(95, -20))
	check(objects.dragging, "Panel did not begin dragging")
	var depth: float = objects.drag_depth
	await mouse(pointer, true, false, MOUSE_BUTTON_WHEEL_UP)
	check(objects.drag_depth > depth + 0.2, "Wheel did not move held panel farther away")
	await mouse(pointer, true, false, MOUSE_BUTTON_RIGHT)
	await mouse(pointer, true, false, MOUSE_BUTTON_WHEEL_UP)
	check(not first_object.basis.is_equal_approx(original.basis), "Both buttons + wheel did not rotate panel")
	await mouse(pointer, false, false, MOUSE_BUTTON_RIGHT)
	await mouse(pointer, false)
	await frames(90)
	check(first_object.support != null and first_object.fall_speed == 0, "Moved panel did not settle on the square")
	check(first_object.position.distance_to(original.origin) > 0.2, "Committed drag did not change placement")
	check(second_object.global_transform.is_equal_approx(other_transform), "Manipulation moved the other application")
	var placed: Transform3D = first_object.global_transform
	var revision: int = first_object.revision
	var pixels: PackedByteArray = first_object.texture.get_image().get_data()
	await capture("placed-applications.png")
	# Walk down the south approach and back through normal controller input.
	# Keep the panels in view so the distant capture documents their location.
	var origin: Vector3 = player.position
	await key(KEY_S, true)
	await frames(300)
	await key(KEY_S, false)
	await frames(5)
	var distance: float = player.position.distance_to(origin)
	check(distance > 11.5 and player.is_on_floor(), "Could not walk away along the south approach: " + str(player.position))
	check(not app.active and terminal.session.keyboard_focus_handle() == 0, "Walking sent keys to an application")
	check(first_object.revision > revision and first_object.texture.get_image().get_data() != pixels, "Background terminal froze while away")
	var background_delta: int = first_object.revision - revision
	check(first_object.global_transform.is_equal_approx(placed) and second_object.global_transform.is_equal_approx(other_transform), "Panels followed the player")
	await capture("away-south-approach.png")
	await key(KEY_W, true)
	deadline = Time.get_ticks_msec() + 9000
	while player.position.z > origin.z + 0.04 and Time.get_ticks_msec() < deadline: await physics_frame
	await key(KEY_W, false)
	await frames(5)
	check(player.position.distance_to(origin) < 0.12 and player.is_on_floor(), "Walk did not return to the original application location")
	check(objects.bindings.get(first) == first_object and first_object.entity_id == first_id, "Walk replaced the terminal entity")
	check(objects.bindings.get(second) == second_object and second_object.entity_id == second_id, "Walk replaced the editor entity")
	check(first_object.global_transform.is_equal_approx(placed) and second_object.global_transform.is_equal_approx(other_transform), "Revisit changed placement/rotation")
	await capture("revisited-applications.png")
	await activate(first)
	await chord(KEY_CTRL, KEY_C)
	await type_text("printf '%s:%s\\n' \"$$\" \"$VILLAGE_SESSION\" | tee '" + output_dir.path_join("after.txt") + "'\n")
	check(await wait_file("after.txt") == before, "Revisit lost the running shell PID or session variable")
	await capture("terminal-revisited.png")
	await return_to_room()
	await activate(second)
	await type_text("RETURNED TO SAME BUFFER")
	await tap(KEY_ESCAPE)
	await type_text(":w " + output_dir.path_join("editor.txt") + "\n")
	check(await wait_file("editor.txt") == "UNSAVED VILLAGE EDITOR\nRETURNED TO SAME BUFFER\n", "Editor buffer or focus did not survive the walk")
	await capture("editor-revisited.png")
	await type_text(":q\n")
	deadline = Time.get_ticks_msec() + 5000
	while objects.bindings.has(second) and Time.get_ticks_msec() < deadline: await process_frame
	check(not objects.bindings.has(second) and objects.bindings.has(first) and not app.active, "Editor close removed the wrong panel or retained focus")
	await settle()
	await activate(first)
	await type_text("exit\n")
	deadline = Time.get_ticks_msec() + 5000
	while not objects.bindings.is_empty() and Time.get_ticks_msec() < deadline: await process_frame
	check(objects.bindings.is_empty() and not app.active and terminal.session.keyboard_focus_handle() == 0 and player._held.is_empty(), "Closing applications left panels, focus or movement behind")
	await capture("world-after-close.png")
	print("VILLAGE_REVISIT distance_one_way_m=", distance, " shell=", before.strip_edges(), " terminal_entity=", first_id, " editor_entity=", second_id, " background_revision_delta=", background_delta)
	await finish()
