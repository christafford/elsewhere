## Actual doorway traversal, interior support and live-shell revisit in all rooms.
extends "res://tests/pavilion_workspace.gd"

const Landscape = preload("res://scripts/village_landscape.gd")
const Architecture = preload("res://scripts/village_architecture.gd")

func local_walk(building: Node3D, point: Vector3) -> void:
	var target := building.to_global(point)
	await walk_to(Vector2(target.x,target.z))

func face(target: Vector3) -> void:
	# Match ordinary mouse look: yaw belongs to the player, pitch to its camera.
	var direction := target-walker.global_position
	walker.rotation.y = atan2(-direction.x,-direction.z)
	walker.camera.look_at(target)

func finish() -> void:
	await study.desktop_runtime.shutdown()
	check(terminal.launched_children.is_empty(), "Interior shutdown left owned clients")
	print("VILLAGE_INTERIORS_OK mode=",DisplayServer.get_name()," failures=",failures)
	quit(1 if failures else 0)

func run() -> void:
	var graphical := DisplayServer.get_name() != "headless"
	output_dir = ProjectSettings.globalize_path("res://../.tools/village-interiors-test").simplify_path()
	DirAccess.make_dir_recursive_absolute(output_dir)
	study = load("res://scenes/main.tscn").instantiate()
	root.add_child(study)
	current_scene = study
	terminal = study.terminal_screen
	app = study.application_mode
	objects = study.application_objects
	walker = study.get_node("Player")
	if graphical: root.grab_focus()
	await frames(20)
	check(objects.bindings.is_empty(),"Interior startup launched an unsolicited app")
	for label in Architecture.ROOMS:
		var building: Node3D = study.get_node("Architecture/"+label)
		var room: Vector3 = Architecture.ROOMS[label]
		var outside := Vector3(room.z,0,room.y+Architecture.ENTRY_RUN+.3)
		var start := building.to_global(outside)
		walker.release_pointer()
		walker.position = Vector3(start.x,Landscape.height_at(Vector2(start.x,start.z))+.05,start.z)
		await frames(15)
		await key(KEY_SHIFT,true)
		await local_walk(building, Vector3(room.z,0,.8))
		await local_walk(building, Vector3(0,0,.8))
		await local_walk(building, Vector3(0,0,-room.y*1.65+1.0))
		await local_walk(building, Vector3(0,0,.8))
		await key(KEY_SHIFT,false)
		check(absf(walker.position.y-building.position.y)<.04,"Interior floor/threshold mismatch: "+label)
		# Sample usable floor throughout the extended room, excluding furniture.
		for x in [-room.x+.6,0,room.x-.6]:
			for z in [-room.y*1.65+.6,-.2,room.y-.6]:
				var point := building.to_global(Vector3(x,.1,z))
				var floor_hit := root.world_3d.direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(point,point-Vector3.UP*.2,1))
				check(not floor_hit.is_empty() and absf(floor_hit.position.y-building.position.y)<.03,"Missing interior floor: "+label+str(point))
		var origin := building.to_global(Vector3(0,1.6,0))
		for direction in [Vector3.LEFT,Vector3.RIGHT,Vector3.UP]:
			var hit := root.world_3d.direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(origin,origin+building.basis*direction*15,1))
			# The forward doorway is intentionally open; back/side/ceiling are solid.
			check(not hit.is_empty(),"Missing interior enclosure: "+label+str(direction))
		var rear := root.world_3d.direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(origin,origin-building.basis.z*15,1))
		check(not rear.is_empty(),"Missing rear wall: "+label)
		face(building.to_global(Vector3(0,1.6,-4)))
		if graphical: await capture(label.to_lower()+"-interior.png")
		var table: StaticBody3D = building.get_node("Interior/Workspace/WestWorktable")
		var anchor: Marker3D = table.get_node("WorkAnchor")
		var fit := PhysicsShapeQueryParameters3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(1.4,1.02,.08)
		fit.shape = box
		fit.collision_mask = 7
		fit.transform.basis = building.global_basis
		for side in ["West", "East"]:
			var pad: Marker3D = building.get_node("Interior/Workspace/"+side+"Worktable/WorkAnchor")
			fit.transform.origin = pad.global_position+Vector3.UP*.54
			check(root.world_3d.direct_space_state.intersect_shape(fit).is_empty(),"Interior desk cannot fit a panel: "+label+side)
		if graphical:
			face(anchor.global_position+Vector3.UP*.5)
			await settle()
			var deadline := Time.get_ticks_msec()+15000
			while study.app_launcher.entries.is_empty() and Time.get_ticks_msec()<deadline: await process_frame
			var handle := await launch_from_search(study.app_launcher.TERMINAL_ID,"Terminal")
			if failures:
				await finish()
				return
			var before_name: String = label+"-before.txt"
			var after_name: String = label+"-after.txt"
			for file in [before_name,after_name]:
				if FileAccess.file_exists(output_dir.path_join(file)): DirAccess.remove_absolute(output_dir.path_join(file))
			await type_text("INTERIOR_SESSION="+label+"; printf '%s:%s\\n' \"$$\" \"$INTERIOR_SESSION\" > '"+output_dir.path_join(before_name)+"'\n")
			var before := await wait_file(before_name)
			check(before.ends_with(":"+label+"\n"),"Initial interior shell state missing: "+label)
			await return_to_room()
			var panel: Node3D = objects.bindings[handle]
			var entity: String = panel.entity_id
			var pointer := point(handle)
			await mouse(pointer,true)
			var target: Vector3 = anchor.global_position+Vector3.UP*(panel.bounds.y*.5+.2)
			var depth: float = -objects.camera.to_local(target).z
			for step in range(35):
				if objects.drag_depth >= depth-.12: break
				await mouse(pointer,true,false,MOUSE_BUTTON_WHEEL_UP)
			await motion(objects.camera.unproject_position(target))
			check(objects.dragging,"Could not drag onto interior desk: "+label)
			await mouse(pointer,false)
			await frames(100)
			check(panel.support != null and panel.support.get_ref()==table,"Interior desk did not support live panel: "+label)
			var placed: Transform3D = panel.global_transform
			await capture(label.to_lower()+"-workspace.png")
			await key(KEY_SHIFT,true)
			await local_walk(building,Vector3(room.z,0,.8))
			await local_walk(building,outside)
			await key(KEY_SHIFT,false)
			check(not app.active and terminal.session.keyboard_focus_handle()==0,"Leaving interior retained app focus")
			face(building.to_global(Vector3(room.z,1.3,room.y)))
			await capture(label.to_lower()+"-entry.png")
			await key(KEY_SHIFT,true)
			await local_walk(building,Vector3(room.z,0,.8))
			await local_walk(building,Vector3(0,0,.8))
			await key(KEY_SHIFT,false)
			check(objects.bindings.get(handle)==panel and panel.entity_id==entity and panel.global_transform.is_equal_approx(placed),"Interior revisit changed panel identity/placement")
			face(panel.global_position)
			await settle()
			await activate(handle)
			await type_text("printf '%s:%s\\n' \"$$\" \"$INTERIOR_SESSION\" | tee '"+output_dir.path_join(after_name)+"'\n")
			check(await wait_file(after_name)==before,"Interior revisit replaced live shell: "+label)
			await capture(label.to_lower()+"-same-shell.png")
			await type_text("exit\n")
			deadline = Time.get_ticks_msec()+5000
			while objects.bindings.has(handle) and Time.get_ticks_msec()<deadline: await process_frame
			check(not objects.bindings.has(handle) and not app.active,"Interior client close failed")
			print("INTERIOR_REVISIT building=",label," shell=",before.strip_edges()," entity=",entity)
		await key(KEY_SHIFT,true)
		await local_walk(building,Vector3(room.z,0,.8))
		await local_walk(building,outside)
		await key(KEY_SHIFT,false)
		check(walker.is_on_floor(),"Could not leave interior: "+label)
		print("INTERIOR_TRAVERSAL building=",label," floor_y=",building.position.y," usable_size=",Vector2(room.x*2-.56,room.y*2.65-.742))
	await tap(KEY_HOME)
	await frames(15)
	check(walker.position.distance_to(Vector3(0,0,5))<.04,"Interiors obstructed Home")
	await finish()
