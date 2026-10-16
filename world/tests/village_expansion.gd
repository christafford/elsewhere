## P22-T11 physical streets, furnished ground floors and real applications.
extends "res://tests/village_interiors.gd"

const Expansion = preload("res://scripts/village_expansion.gd")
const Lanes = preload("res://scripts/village_lanes.gd")

func finish() -> void:
	await study.desktop_runtime.shutdown()
	check(terminal.launched_children.is_empty() and not terminal.child_running(),"Expansion shutdown left owned clients")
	print("VILLAGE_EXPANSION_OK mode=",DisplayServer.get_name()," buildings=10 failures=",failures)
	quit(1 if failures else 0)

func live_trial(building: Node3D, spec: Dictionary, outside: Vector3) -> void:
	var label: String = spec.id
	var table: StaticBody3D = building.get_node("Worktable")
	var anchor: Marker3D = table.get_node("WorkAnchor")
	face(anchor.global_position+Vector3.UP*.5)
	await settle()
	var deadline := Time.get_ticks_msec()+15000
	while study.app_launcher.entries.is_empty() and Time.get_ticks_msec()<deadline: await process_frame
	var handle := await launch_from_search(study.app_launcher.TERMINAL_ID,"Terminal")
	if failures: return
	var before_name := label+"-before.txt"
	var after_name := label+"-after.txt"
	for file in [before_name,after_name]:
		if FileAccess.file_exists(output_dir.path_join(file)): DirAccess.remove_absolute(output_dir.path_join(file))
	await type_text("VILLAGE_TRADE="+label+"; printf '%s:%s\\n' \"$$\" \"$VILLAGE_TRADE\" > '"+output_dir.path_join(before_name)+"'\n")
	var before := await wait_file(before_name)
	check(before.ends_with(":"+label+"\n"),"Trade shell state missing: "+label)
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
	check(objects.dragging,"Could not drag onto trade worktable: "+label)
	await mouse(pointer,false)
	await frames(100)
	check(panel.support != null and panel.support.get_ref()==table,"Trade worktable did not support panel: "+label)
	var placed: Transform3D = panel.global_transform
	await capture(label.to_lower()+"-workspace.png")
	await key(KEY_SHIFT,true)
	await local_walk(building,Vector3(0,0,1.1))
	await local_walk(building,outside)
	await key(KEY_SHIFT,false)
	check(not app.active and terminal.session.keyboard_focus_handle()==0,"World walk retained keyboard focus")
	face(building.to_global(Vector3(0,2.8,spec.depth/2)))
	await capture(label.to_lower()+"-entry.png")
	await key(KEY_SHIFT,true)
	await local_walk(building,Vector3(0,0,1.1))
	await key(KEY_SHIFT,false)
	check(objects.bindings.get(handle)==panel and panel.entity_id==entity and panel.global_transform.is_equal_approx(placed),"Trade revisit changed entity or placement: "+label)
	face(panel.global_position)
	await settle()
	await activate(handle)
	await type_text("printf '%s:%s\\n' \"$$\" \"$VILLAGE_TRADE\" | tee '"+output_dir.path_join(after_name)+"'\n")
	check(await wait_file(after_name)==before,"Trade revisit replaced shell state: "+label)
	await capture(label.to_lower()+"-same-shell.png")
	await type_text("exit\n")
	deadline = Time.get_ticks_msec()+5000
	while objects.bindings.has(handle) and Time.get_ticks_msec()<deadline: await process_frame
	check(not objects.bindings.has(handle) and not app.active,"Trade client close failed")
	print("EXPANSION_REVISIT building=",label," shell=",before.strip_edges()," entity=",entity)

func run() -> void:
	var graphical := DisplayServer.get_name() != "headless"
	var captures_only := "--capture-only" in OS.get_cmdline_user_args()
	output_dir = ProjectSettings.globalize_path("res://../.tools/p22-t11/expansion").simplify_path()
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
	check(study.get_node("VillageExtension").get_child_count()==10,"Expected exactly ten new buildings")
	check(objects.bindings.is_empty() and terminal.session.is_running(),"Expansion changed empty desktop startup")
	if not captures_only:
		for label in Lanes.ROUTES:
			var route: Array = Lanes.ROUTES[label]
			walker.release_pointer()
			walker.position = Vector3(route[0].x,Landscape.height_at(route[0])+.05,route[0].y)
			await frames(15)
			await key(KEY_SHIFT,true)
			for p in route.slice(1): await walk_to(p)
			var reverse := route.duplicate()
			reverse.reverse()
			for p in reverse.slice(1): await walk_to(p)
			await key(KEY_SHIFT,false)
			print("EXPANSION_LANE ",label)
			if failures:
				await finish()
				return
	for spec in Expansion.definitions():
		var label: String = spec.id
		var building: Node3D = study.get_node("VillageExtension/"+label)
		var outside := Vector3(0,0,spec.depth/2+3.3)
		var start := building.to_global(outside)
		walker.release_pointer()
		walker.position = Vector3(start.x,Landscape.height_at(Vector2(start.x,start.z))+.05,start.z)
		await frames(15)
		check(walker.is_on_floor(),"No approach support: "+label)
		face(building.to_global(Vector3(0,3.4,0)))
		if graphical: await capture(label.to_lower()+"-exterior.png")
		for x in [-spec.width/2, spec.width/2]:
			for z in [-spec.depth/2,spec.depth/2]:
				var corner := building.to_global(Vector3(x,0,z))
				check(Landscape.contains(Vector2(corner.x,corner.z),.6),"Building clips bank: "+label)
		await key(KEY_SHIFT,true)
		await local_walk(building,Vector3(0,0,1.1))
		await local_walk(building,Vector3(0,0,-spec.depth/2+1.6))
		await local_walk(building,Vector3(0,0,1.1))
		await key(KEY_SHIFT,false)
		check(absf(walker.position.y-building.position.y)<.04,"Floor mismatch: "+label)
		for x in [-spec.width/2+.5,0,spec.width/2-.5]:
			for z in [-spec.depth/2+.5,0,spec.depth/2-.5]:
				var p := building.to_global(Vector3(x,.08,z))
				var hit := root.world_3d.direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(p,p-Vector3.UP*.16,1))
				check(not hit.is_empty() and absf(hit.position.y-building.position.y)<.03,"Missing floor: "+label+str(p))
		var origin := building.to_global(Vector3(0,1.7,0))
		for direction in [Vector3.LEFT,Vector3.RIGHT,Vector3.UP,Vector3.FORWARD]:
			var hit := root.world_3d.direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(origin,origin+building.basis*direction*15,1))
			check(not hit.is_empty(),"Missing enclosure: "+label)
		var anchor: Marker3D = building.get_node("Worktable/WorkAnchor")
		var query := PhysicsShapeQueryParameters3D.new()
		var shape := BoxShape3D.new()
		shape.size = Vector3(1.4,1.02,.08)
		query.shape = shape
		query.collision_mask = 7
		query.transform = Transform3D(building.global_basis,anchor.global_position+Vector3.UP*.54)
		check(root.world_3d.direct_space_state.intersect_shape(query).is_empty(),"Trade worktable lacks panel clearance: "+label)
		face(building.to_global(Vector3(.5,1.35,-spec.depth/2+.5)))
		if graphical:
			await capture(label.to_lower()+"-interior.png")
			face(building.to_global(Vector3(spec.width/2-1,1,-.8)))
			await capture(label.to_lower()+"-artifacts.png")
			if not captures_only: await live_trial(building,spec,outside)
		if failures:
			await finish()
			return
		await key(KEY_SHIFT,true)
		await local_walk(building,outside)
		await key(KEY_SHIFT,false)
		print("EXPANSION_INTERIOR ",label," floor_y=",building.position.y)
	await tap(KEY_HOME)
	await frames(15)
	check(walker.position.distance_to(Vector3(0,0,5))<.04 and walker.is_on_floor(),"Expansion obstructed Home")
	await finish()
