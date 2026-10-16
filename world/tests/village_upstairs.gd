## Real stair traversal and upstairs live-shell placement in six village buildings.
extends "res://tests/village_interiors.gd"

const Upstairs = preload("res://scripts/village_upstairs.gd")
var graphical := false

func finish() -> void:
	await study.desktop_runtime.shutdown()
	check(terminal.launched_children.is_empty() and not terminal.child_running(),"Upstairs shutdown left owned clients")
	print("VILLAGE_UPSTAIRS_OK mode=",DisplayServer.get_name()," buildings=6 failures=",failures)
	quit(1 if failures else 0)

func probe_headroom(building: Node3D, local: Vector3, label: String) -> void:
	var p := building.to_global(local)
	var hit := root.world_3d.direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(p+Vector3.UP*.2,p+Vector3.UP*2.1,1))
	check(hit.is_empty(),"Insufficient 2.1m stair/room headroom: "+label+str(local))

func ascend(building: Node3D, spec: Dictionary, capture_views: bool = false) -> void:
	var points := Upstairs.stair_points(spec)
	var bottom := points[0]
	var top := points[1]
	await local_walk(building,Vector3(0,0,bottom.z+.28))
	await local_walk(building,bottom+Vector3(0,0,.28))
	if graphical and capture_views:
		face(building.to_global(top+Vector3.UP))
		await capture(spec.id.to_lower()+"-stairs.png")
	for i in range(1,11):
		var p := bottom.lerp(top,i/10.0)
		await local_walk(building,p)
		if failures: return
		var actual := building.to_local(walker.global_position)
		var guide_y: float = clampf((bottom.z-actual.z)/Upstairs.RUN,0,1)*Upstairs.FLOOR
		check(absf(actual.y-guide_y)<.08,"Stair ascent lost fitted support: "+spec.id+str(actual))
		probe_headroom(building,p,spec.id)
		if graphical and capture_views and i==5:
			face(building.to_global(top+Vector3.UP))
			await capture(spec.id.to_lower()+"-midflight.png")
	await local_walk(building,top+Vector3(0,0,-.45))
	if graphical and capture_views:
		face(building.to_global(bottom+Vector3.UP))
		await capture(spec.id.to_lower()+"-landing.png")
	await local_walk(building,Vector3(1.25,Upstairs.FLOOR,top.z-.45))
	await local_walk(building,Vector3(1.25,Upstairs.FLOOR,.65))
	await local_walk(building,Vector3(0,Upstairs.FLOOR,.65))
	check(absf(building.to_local(walker.global_position).y-Upstairs.FLOOR)<.04,"Upstairs floor mismatch: "+spec.id)
	probe_headroom(building,Vector3(0,Upstairs.FLOOR,.65),spec.id)

func descend(building: Node3D, spec: Dictionary) -> void:
	var points := Upstairs.stair_points(spec)
	await local_walk(building,Vector3(1.25,Upstairs.FLOOR,.65))
	await local_walk(building,Vector3(1.25,Upstairs.FLOOR,points[1].z-.45))
	await local_walk(building,points[1]+Vector3(0,0,-.45))
	for i in range(10,-1,-1):
		var p: Vector3 = points[0].lerp(points[1],i/10.0)
		await local_walk(building,p)
		if failures: return
		var actual := building.to_local(walker.global_position)
		var guide_y: float = clampf((points[0].z-actual.z)/Upstairs.RUN,0,1)*Upstairs.FLOOR
		check(absf(actual.y-guide_y)<.08,"Stair descent lost fitted support: "+spec.id+str(actual))
	await local_walk(building,points[0]+Vector3(0,0,.28))
	await local_walk(building,Vector3(0,0,points[0].z+.28))
	await local_walk(building,Vector3(0,0,spec.depth/2+3.3))
	check(walker.is_on_floor(),"Stair descent did not reach exterior: "+spec.id)

func live_trial(building: Node3D, spec: Dictionary) -> void:
	var table: StaticBody3D = building.get_node("Upstairs/Workspace/Worktable")
	var anchor: Marker3D = table.get_node("WorkAnchor")
	face(anchor.global_position+Vector3.UP*.5)
	await settle()
	var deadline := Time.get_ticks_msec()+15000
	while study.app_launcher.entries.is_empty() and Time.get_ticks_msec()<deadline: await process_frame
	var handle := await launch_from_search(study.app_launcher.TERMINAL_ID,"Terminal")
	if failures: return
	var before_name: String = spec.id+"-before.txt"
	var after_name: String = spec.id+"-after.txt"
	for file in [before_name,after_name]:
		if FileAccess.file_exists(output_dir.path_join(file)): DirAccess.remove_absolute(output_dir.path_join(file))
	await type_text("UPSTAIRS_ROOM="+spec.id+"; printf '%s:%s\\n' \"$$\" \"$UPSTAIRS_ROOM\" > '"+output_dir.path_join(before_name)+"'\n")
	var before := await wait_file(before_name)
	check(before.ends_with(":"+spec.id+"\n"),"Upstairs shell state missing")
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
	check(objects.dragging,"Could not drag upstairs terminal")
	await mouse(pointer,false)
	await frames(100)
	check(panel.support != null and panel.support.get_ref()==table,"Upstairs worktable did not support terminal")
	var placed: Transform3D = panel.global_transform
	await capture(spec.id.to_lower()+"-workspace.png")
	await descend(building,spec)
	check(not app.active and terminal.session.keyboard_focus_handle()==0,"Leaving upstairs retained app focus")
	await ascend(building,spec)
	check(objects.bindings.get(handle)==panel and panel.entity_id==entity and panel.global_transform.is_equal_approx(placed),"Upstairs revisit changed entity/placement")
	face(panel.global_position)
	await settle()
	await activate(handle)
	await type_text("printf '%s:%s\\n' \"$$\" \"$UPSTAIRS_ROOM\" | tee '"+output_dir.path_join(after_name)+"'\n")
	check(await wait_file(after_name)==before,"Upstairs revisit replaced shell")
	await capture(spec.id.to_lower()+"-same-shell.png")
	await type_text("exit\n")
	deadline = Time.get_ticks_msec()+5000
	while objects.bindings.has(handle) and Time.get_ticks_msec()<deadline: await process_frame
	check(not objects.bindings.has(handle) and not app.active,"Upstairs client close failed")
	print("UPSTAIRS_REVISIT building=",spec.id," shell=",before.strip_edges()," entity=",entity)

func run() -> void:
	graphical = DisplayServer.get_name() != "headless"
	var captures_only := "--capture-only" in OS.get_cmdline_user_args()
	output_dir = ProjectSettings.globalize_path("res://../.tools/p22-t12/upstairs").simplify_path()
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
	check(objects.bindings.is_empty() and terminal.session.is_running(),"Upstairs changed empty desktop startup")
	check(Upstairs.definitions().size()==6,"Expected six upstairs rooms")
	for spec in Upstairs.definitions():
		var building: Node3D = study.get_node(spec.path)
		var outside := building.to_global(Vector3(0,0,spec.depth/2+3.3))
		walker.release_pointer()
		walker.position = Vector3(outside.x,Landscape.height_at(Vector2(outside.x,outside.z))+.05,outside.z)
		await frames(15)
		await local_walk(building,Vector3(0,0,.8))
		if graphical:
			face(building.to_global(Vector3(spec.width/2-1,2,0)))
			await capture(spec.id.to_lower()+"-downstairs.png")
		await ascend(building,spec,true)
		if failures:
			await finish()
			return
		if graphical:
			face(building.to_global(Vector3(-1.5,4.7,-spec.depth/2*spec.rear_scale+.7)))
			await capture(spec.id.to_lower()+"-upstairs.png")
		# Walk into the continuous stairwell guard; it must prevent a fall.
		var guard_z: float = Upstairs.stair_points(spec)[0].z-1.4
		await local_walk(building,Vector3(1.25,Upstairs.FLOOR,guard_z))
		face(building.to_global(Vector3(spec.width/2,Upstairs.FLOOR+1.6,guard_z)))
		await key(KEY_W,true)
		await frames(65)
		await key(KEY_W,false)
		var local := building.to_local(walker.global_position)
		check(local.x<spec.width/2-1.65 and absf(local.y-Upstairs.FLOOR)<.05,"Stairwell guard failed: "+spec.id+str(local))
		await local_walk(building,Vector3(0,Upstairs.FLOOR,.65))
		var origin := building.to_global(Vector3(0,Upstairs.FLOOR+1.5,.65))
		for direction in [Vector3.LEFT,Vector3.RIGHT,Vector3.UP,Vector3.FORWARD,Vector3.BACK]:
			var hit := root.world_3d.direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(origin,origin+building.basis*direction*20,1))
			check(not hit.is_empty(),"Missing upstairs enclosure: "+spec.id+str(direction))
		for x in [0,1.25]:
			for z in [.65,-.5]:
				var p := building.to_global(Vector3(x,Upstairs.FLOOR+.1,z))
				var hit := root.world_3d.direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(p,p-Vector3.UP*.2,1))
				check(not hit.is_empty() and absf(hit.position.y-building.position.y-Upstairs.FLOOR)<.03,"Missing upstairs floor: "+spec.id)
		var pad: Marker3D = building.get_node("Upstairs/Workspace/Worktable/WorkAnchor")
		var fit := PhysicsShapeQueryParameters3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(1.4,1.02,.08)
		fit.shape = box
		fit.collision_mask = 7
		fit.transform = Transform3D(building.global_basis,pad.global_position+Vector3.UP*.54)
		check(root.world_3d.direct_space_state.intersect_shape(fit).is_empty(),"Upstairs desk lacks panel clearance: "+spec.id)
		if graphical and not captures_only: await live_trial(building,spec)
		if failures:
			await finish()
			return
		await key(KEY_CTRL,true)
		await descend(building,spec)
		await key(KEY_CTRL,false)
		await ascend(building,spec)
		await tap(KEY_HOME)
		await frames(15)
		check(walker.position.distance_to(Vector3(0,0,5))<.04 and walker.is_on_floor(),"Upstairs Home return failed")
		print("UPSTAIRS_TRAVERSAL building=",spec.id," floor_y=",building.position.y+Upstairs.FLOOR)
		if failures:
			await finish()
			return
	await finish()
