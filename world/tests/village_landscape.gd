## P22-T03: actual ground queries and controller traversal, not a navmesh proxy.
extends "res://tests/application_objects.gd"

const Landscape = preload("res://scripts/village_landscape.gd")
var walker: CharacterBody3D
var samples := 0
var walked := 0.0
var steepest := 0.0
var max_floor_gap := 0.0

func frames(count: int) -> void:
	for i in range(count): await physics_frame

func ground_at(p: Vector2) -> Dictionary:
	return root.world_3d.direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(p.x,15,p.y),Vector3(p.x,-5,p.y),1))

func place_at(p: Vector2) -> void:
	walker.release_pointer()
	walker.position = Vector3(p.x,Landscape.height_at(p)+0.05,p.y)
	await frames(15)
	check(walker.is_on_floor(), "No support at trial start: " + str(p))

func steer(target: Vector2) -> void:
	var d := target - Vector2(walker.position.x,walker.position.z)
	var yaw := atan2(-d.x,-d.y)
	# Headless DisplayServer cannot capture a pointer; set only its heading.
	# Both modes still walk through the unchanged physics controller.
	if DisplayServer.get_name() == "headless":
		walker.rotation.y = yaw
		return
	var look := InputEventMouseMotion.new()
	look.screen_relative = Vector2(-wrapf(yaw-walker.rotation.y,-PI,PI)/walker.LOOK_SENSITIVITY,0)
	Input.parse_input_event(look)
	await process_frame

func walk_to(target: Vector2) -> bool:
	var start := Vector2(walker.position.x,walker.position.z)
	var deadline := Time.get_ticks_msec() + int(start.distance_to(target)/walker.FAST_SPEED*1600) + 2000
	await steer(target)
	await key(KEY_W,true)
	while Vector2(walker.position.x,walker.position.z).distance_to(target) > 0.14 and Time.get_ticks_msec() < deadline:
		await steer(target)
		await physics_frame
		var p := Vector2(walker.position.x,walker.position.z)
		max_floor_gap = maxf(max_floor_gap,absf(walker.position.y-Landscape.height_at(p)))
	await key(KEY_W,false)
	var arrived := Vector2(walker.position.x,walker.position.z).distance_to(target) < 0.18
	check(arrived, "Path blocked: target=%s actual=%s" % [target,walker.position])
	walked += start.distance_to(Vector2(walker.position.x,walker.position.z))
	return arrived

func view(name: String, p: Vector2, toward: Vector2) -> void:
	await place_at(p)
	walker.rotation.y = atan2(p.x-toward.x,p.y-toward.y)
	walker.camera.rotation.x = -0.12
	await capture(name+".png")

func run() -> void:
	output_dir = ProjectSettings.globalize_path("res://../.tools/village-landscape-test").simplify_path()
	DirAccess.make_dir_recursive_absolute(output_dir)
	study = load(ProjectSettings.get_setting("application/run/main_scene")).instantiate()
	root.add_child(study)
	current_scene = study
	terminal = study.terminal_screen
	app = study.application_mode
	objects = study.application_objects
	walker = study.get_node("Player")
	await frames(15)
	check(terminal.session != null and terminal.session.is_running() and objects.bindings.is_empty(), "Landscape did not retain the empty desktop runtime")
	check(walker.is_on_floor() and absf(walker.position.y)<0.03, "Arrival is not grounded on the square")
	var min_height := INF
	var max_height := -INF
	# Sample every half-meter cell center throughout the playable site, including
	# square/path edges. Rays must hit the rendered terrain, not a fallback floor.
	for z in range(-84,84):
		for x in range(-84,84):
			var p := Vector2(x*0.5+0.25,z*0.5+0.25)
			if not Landscape.contains(p,0.4): continue
			var hit := ground_at(p)
			if hit.is_empty():
				check(false,"Missing ground at " + str(p))
				continue
			samples += 1
			check(str(hit.collider.get_parent().name)=="Ground", "Unexpected obstacle in playable ground at " + str(p))
			check(absf(hit.position.y-Landscape.height_at(p))<0.015, "Render/collision grade mismatch at " + str(p))
			min_height = minf(min_height,hit.position.y)
			max_height = maxf(max_height,hit.position.y)
			steepest = maxf(steepest,rad_to_deg(acos(clampf(hit.normal.y,-1,1))))
	check(samples>20000 and max_height-min_height>2.5, "Map is missing its intended extent or gentle variation")
	check(steepest<20.0,"Ground slope exceeds the walking grade budget: " + str(steepest))
	# Placement respects the terrain beneath the entire panel and convex boundary.
	for desired in [Vector3(0,-5,0),Vector3(-31,-5,-16),Vector3(32,-5,14),Vector3(100,1,100),Vector3(-100,1,-100)]:
		var extents := Vector3(1,0.7,0.5)
		var bounded: Vector3 = study.bounded_center(desired,extents)
		for x in [-extents.x,0.0,extents.x]:
			for z in [-extents.z,0.0,extents.z]:
				var p := Vector2(bounded.x+x,bounded.z+z)
				check(Landscape.contains(p,0.1) and bounded.y-extents.y>Landscape.height_at(p)+0.05,"Panel bounds clip terrain/bank")
	if failures:
		await study.desktop_runtime.shutdown()
		quit(1)
		return
	if DisplayServer.get_name() != "headless":
		root.grab_focus()
		await settle()
		await view("arrival",Vector2(0,5),Vector2(0,-12))
		await view("south-approach",Vector2(-6,28),Vector2(0,0))
		await view("west-rise",Vector2(-28,-9),Vector2(1,1))
		await view("north-saddle",Vector2(6,-28),Vector2(0,2))
		await view("east-shelf",Vector2(28,8),Vector2(0,0))
	if "--capture-only" in OS.get_cmdline_user_args():
		check(DisplayServer.get_name() != "headless", "Capture-only requires a graphical renderer")
		await study.desktop_runtime.shutdown()
		print("LANDSCAPE_CAPTURE_OK failures=",failures)
		quit(1 if failures else 0)
		return
	# Each route runs endpoint -> square -> endpoint, walking up and down every
	# grade and crossing every paving join. No teleport inside a tested route.
	for label in Landscape.ROUTES:
		var route: Array = Landscape.ROUTES[label]
		await place_at(route.back())
		walker.camera.rotation.x = walker.DEFAULT_PITCH
		await mouse(Vector2(640,400),true,false,MOUSE_BUTTON_RIGHT)
		await key(KEY_SHIFT,true)
		var reverse := route.duplicate()
		reverse.reverse()
		var okay := true
		for p in reverse.slice(1) + [Vector2.ZERO] + route:
			if not await walk_to(p):
				okay = false
				break
		await key(KEY_SHIFT,false)
		await mouse(Vector2(640,400),false,false,MOUSE_BUTTON_RIGHT)
		print("LANDSCAPE_ROUTE ",label," round_trip=",okay," endpoint_y=",walker.position.y)
	# Walk laterally across both square aprons; no collision curb or hidden step.
	await place_at(Vector2(-16,7))
	await mouse(Vector2(640,400),true,false,MOUSE_BUTTON_RIGHT)
	await key(KEY_SHIFT,true)
	await walk_to(Vector2(16,7))
	await key(KEY_SHIFT,false)
	await mouse(Vector2(640,400),false,false,MOUSE_BUTTON_RIGHT)
	check(max_floor_gap<0.08,"Traversal lost continuous ground support: " + str(max_floor_gap))
	await tap(KEY_HOME)
	await frames(15)
	check(walker.position.distance_to(Vector3(0,0,5))<0.03 and walker.is_on_floor(),"Home returns to unsafe ground")
	await study.desktop_runtime.shutdown()
	print("VILLAGE_LANDSCAPE_OK mode=",DisplayServer.get_name()," samples=",samples," walked_m=",snappedf(walked,0.1)," max_grade_deg=",snappedf(steepest,0.01)," floor_gap=",max_floor_gap," failures=",failures)
	quit(1 if failures else 0)
