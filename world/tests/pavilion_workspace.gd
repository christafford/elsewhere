## Real shell, physics-supported placement and ordinary walking in the pavilion.
extends "res://tests/village_applications.gd"

var walker: CharacterBody3D

func walk_to(target: Vector2) -> void:
	var deadline := Time.get_ticks_msec() + 18000
	await key(KEY_W, true)
	while Vector2(walker.position.x, walker.position.z).distance_to(target) > 0.12 and Time.get_ticks_msec() < deadline:
		var delta := target - Vector2(walker.position.x, walker.position.z)
		walker.rotation.y = atan2(-delta.x, -delta.y)
		await physics_frame
	await key(KEY_W, false)
	await frames(5)
	check(Vector2(walker.position.x, walker.position.z).distance_to(target) < 0.16 and walker.is_on_floor(), "Walking route blocked: %s actual=%s" % [target, walker.position])

func finish() -> void:
	await study.desktop_runtime.shutdown()
	check(terminal.launched_children.is_empty() and not terminal.child_running(), "Shutdown left owned children")
	print("PAVILION_WORKSPACE_OK failures=", failures)
	quit(1 if failures else 0)

func run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Pavilion real-client visual trial requires a display")
		quit(1)
		return
	output_dir = ProjectSettings.globalize_path("res://../.tools/pavilion-workspace-test").simplify_path()
	DirAccess.make_dir_recursive_absolute(output_dir)
	for file in ["before.txt", "after.txt"]:
		if FileAccess.file_exists(output_dir.path_join(file)): DirAccess.remove_absolute(output_dir.path_join(file))
	study = load(ProjectSettings.get_setting("application/run/main_scene")).instantiate()
	root.add_child(study)
	current_scene = study
	terminal = study.terminal_screen
	app = study.application_mode
	objects = study.application_objects
	walker = study.get_node("Player")
	root.grab_focus()
	await settle()
	var workspace: Node3D = study.get_node("Architecture/Pavilion/Workspace")
	var table: StaticBody3D = workspace.get_node("WestWorktable")
	var anchor: Marker3D = table.get_node("WorkAnchor")
	check(objects.bindings.is_empty(), "Startup must remain empty")
	await key(KEY_SHIFT, true)
	await walk_to(Vector2(-12,8))
	await walk_to(Vector2(-18,8))
	await capture("pavilion-arrival.png")
	await walk_to(Vector2(-18,17))
	await walk_to(Vector2(-18,19))
	await walk_to(Vector2(-20,19))
	await key(KEY_SHIFT, false)
	walker.rotation.y = 0
	walker.camera.rotation = Vector3(-0.12,0,0)
	await settle()
	await capture("worktables.png")
	var deadline := Time.get_ticks_msec() + 15000
	while study.app_launcher.entries.is_empty() and Time.get_ticks_msec() < deadline: await process_frame
	var handle := await launch_from_search(study.app_launcher.TERMINAL_ID, "Terminal")
	if failures:
		await finish()
		return
	var panel: Node3D = objects.bindings[handle]
	var entity: String = panel.entity_id
	await type_text("PAVILION_SESSION=at-my-desk; printf '%s:%s\\n' \"$$\" \"$PAVILION_SESSION\" > '" + output_dir.path_join("before.txt") + "'\n")
	var before := await wait_file("before.txt")
	check(before.ends_with(":at-my-desk\n"), "Shell session state missing")
	await type_text("while true; do printf 'PAVILION LIVE '; date +%T; sleep 0.5; done\n")
	await return_to_room()
	var pointer := point(handle)
	await mouse(pointer,true)
	# Wheel chooses depth, pointer chooses position; no panel transform assignment.
	var target: Vector3 = anchor.global_position + Vector3.UP * (panel.bounds.y * 0.5 + 0.2)
	var desired_depth: float = -objects.camera.to_local(target).z
	check(objects.pressed == handle, "Could not grab the live panel")
	for step in range(28):
		if objects.drag_depth >= desired_depth - 0.12: break
		await mouse(pointer,true,false,MOUSE_BUTTON_WHEEL_UP)
	await motion(objects.camera.unproject_position(target))
	check(objects.dragging, "Panel did not drag toward chosen work pad")
	await mouse(pointer,false)
	await frames(100)
	check(panel.support != null and panel.support.get_ref() == table and panel.fall_speed == 0, "Panel did not land on the worktable")
	var offset: Vector3 = table.to_local(panel.global_position) - table.to_local(anchor.global_position)
	check(absf(offset.x) < 0.15 and absf(offset.z) < 0.28 and absf(offset.y-panel.bounds.y*0.5) < 0.02, "Panel missed raised placement pad: " + str(offset))
	var placed: Transform3D = panel.global_transform
	await capture("terminal-on-worktable.png")
	# Move and rotate the other supported object through the shared controls.
	await walk_to(Vector2(-18,19))
	var stool: RigidBody3D = workspace.get_node("EastStool")
	walker.camera.look_at(stool.to_global(stool.placement_box.get_center()))
	await settle()
	pointer = objects.camera.unproject_position(stool.to_global(stool.placement_box.get_center()))
	check(objects.pick_furniture(pointer) == stool, "Stool is not pickable")
	var original: Transform3D = stool.global_transform
	await mouse(pointer,true)
	await motion(pointer + Vector2(-70,-120))
	check(stool.freeze and objects.furniture == stool and stool.position.distance_to(original.origin) > 0.15, "Stool did not carry")
	await mouse(pointer,true,false,MOUSE_BUTTON_RIGHT)
	await mouse(pointer,true,false,MOUSE_BUTTON_WHEEL_UP)
	await mouse(pointer,false,false,MOUSE_BUTTON_RIGHT)
	check(not stool.basis.is_equal_approx(original.basis), "Stool did not rotate")
	await mouse(pointer,false)
	await frames(100)
	check(not stool.freeze and not objects.has_grab() and stool.position.distance_to(original.origin)>0.15, "Stool move did not commit")
	check(absf(stool.global_position.y-workspace.global_position.y)<0.05, "Stool did not settle on pavilion floor")
	check(panel.global_transform.is_equal_approx(placed), "Moving another object moved the application")
	var stool_placed: Transform3D = stool.global_transform
	await capture("stool-moved.png")
	# A subsequent cancelled manipulation restores the committed placement.
	pointer = objects.camera.unproject_position(stool.to_global(stool.placement_box.get_center()))
	await mouse(pointer,true)
	await motion(pointer+Vector2(0,-80))
	await tap(KEY_ESCAPE)
	await mouse(pointer,false)
	await frames(30)
	check(stool.global_position.distance_to(stool_placed.origin)<0.03 and not stool.freeze, "Stool cancellation lost placement")
	var revision: int = panel.revision
	var pixels: PackedByteArray = panel.texture.get_image().get_data()
	walker.camera.rotation = Vector3(-0.12,0,0)
	await key(KEY_SHIFT,true)
	await walk_to(Vector2(-18,8))
	await walk_to(Vector2(-8,8))
	await key(KEY_SHIFT,false)
	walker.camera.look_at(panel.global_position)
	await capture("away-in-square.png")
	check(panel.revision > revision and panel.texture.get_image().get_data()!=pixels, "Live shell stopped updating while away")
	check(not app.active and terminal.session.keyboard_focus_handle()==0, "World walking activated client input")
	await key(KEY_SHIFT,true)
	walker.camera.rotation = Vector3(-0.12,0,0)
	await walk_to(Vector2(-18,8))
	await walk_to(Vector2(-18,17))
	await walk_to(Vector2(-18,19))
	await walk_to(Vector2(-20,19))
	await key(KEY_SHIFT,false)
	walker.rotation.y = 0
	walker.camera.rotation = Vector3(-0.12,0,0)
	await settle()
	check(objects.bindings.get(handle)==panel and panel.entity_id==entity and panel.global_transform.is_equal_approx(placed), "Revisit changed panel identity or placement")
	check(stool.global_position.distance_to(stool_placed.origin)<0.03, "Stool placement changed while away")
	var background_delta: int = panel.revision-revision
	await capture("workspace-revisited.png")
	await activate(handle)
	await chord(KEY_CTRL,KEY_C)
	await type_text("printf '%s:%s\\n' \"$$\" \"$PAVILION_SESSION\" | tee '" + output_dir.path_join("after.txt") + "'\n")
	check(await wait_file("after.txt")==before, "Revisit replaced the shell or lost its variable")
	await capture("same-shell.png")
	await type_text("exit\n")
	deadline = Time.get_ticks_msec()+5000
	while not objects.bindings.is_empty() and Time.get_ticks_msec()<deadline: await process_frame
	check(objects.bindings.is_empty() and not app.active, "Client-owned close failed")
	print("PAVILION_REVISIT shell=",before.strip_edges()," entity=",entity," anchor_offset=",offset," background_revisions=",background_delta, " placed=",placed)
	await finish()
