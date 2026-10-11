## P22-T04: real model collision, open routes and human-eye-height captures.
extends "res://tests/village_landscape.gd"

func architecture_view(label: String, xz: Vector2, target: Vector3) -> void:
	await place_at(xz)
	walker.camera.look_at(target)
	await capture(label+".png")
	walker.camera.rotation = Vector3.ZERO

func run() -> void:
	output_dir = ProjectSettings.globalize_path("res://../.tools/village-architecture-test").simplify_path()
	DirAccess.make_dir_recursive_absolute(output_dir)
	study = load(ProjectSettings.get_setting("application/run/main_scene")).instantiate()
	root.add_child(study)
	current_scene = study
	terminal = study.terminal_screen
	app = study.application_mode
	objects = study.application_objects
	walker = study.get_node("Player")
	await frames(20)
	var architecture := study.get_node("Architecture")
	check(architecture.get_child_count()==5,"Expected three exteriors, landmark and pavilion")
	check(terminal.session != null and terminal.session.is_running() and objects.bindings.is_empty(),"Architecture changes empty desktop startup")
	for label in ["Lodge","Guildhall","Workshop","Fountain","Pavilion"]:
		var node := architecture.get_node(label)
		check(not node.find_children("*","MeshInstance3D").is_empty(),"Missing authored model: " + label)
	if DisplayServer.get_name() != "headless":
		root.grab_focus()
		await architecture_view("arrival",Vector2(0,5),Vector3(-4,2,-10))
		await architecture_view("east-square",Vector2(13,10),Vector3(-5,2,-9))
		await architecture_view("north-return",Vector2(4,-12),Vector3(-9,2,8))
		await architecture_view("lodge",Vector2(-10,-2),Vector3(-12,4,-16))
		await architecture_view("guildhall",Vector2(8,-5),Vector3(9.5,5,-17))
		await architecture_view("workshop",Vector2(9,-7),Vector3(18,3,-9))
		await architecture_view("pavilion",Vector2(-4,19),Vector3(-18,3,18))
		await architecture_view("south-approach",Vector2(-6,28),Vector3(-3,2,-6))
		# P22-T05 close views expose texture scale, contact and leaf shading.
		await architecture_view("plaster-timber",Vector2(-8,-9),Vector3(-10.4,2.5,-12.2))
		await architecture_view("paving-fountain",Vector2(-5,1.5),Vector3(-5,1,-4))
		await architecture_view("foliage",Vector2(-19,-11),Vector3(-22,5,-16))
	if "--capture-only" in OS.get_cmdline_user_args():
		check(DisplayServer.get_name() != "headless","Capture-only requires a graphical renderer")
		await study.desktop_runtime.shutdown()
		print("ARCHITECTURE_CAPTURE_OK failures=",failures)
		quit(1 if failures else 0)
		return
	# Walking into each sealed exterior must stop at its real facade collision.
	for entry in [["Lodge",3.75],["Guildhall",3.25],["Workshop",3.25]]:
		var model: Node3D = architecture.get_node(entry[0])
		var start: Vector3 = model.to_global(Vector3(2.8,0,entry[1]+3.0))
		await place_at(Vector2(start.x,start.z))
		walker.rotation.y = model.rotation.y
		await key(KEY_W,true)
		await frames(70)
		await key(KEY_W,false)
		var local := model.to_local(walker.position)
		check(local.z>entry[1]+0.15 and local.z<entry[1]+1.0 and walker.is_on_floor(),"Closed exterior collision failed: %s %s" % [entry[0],local])
	await place_at(Vector2(-5,1))
	walker.rotation.y = 0
	await key(KEY_W,true)
	await frames(80)
	await key(KEY_W,false)
	check(walker.position.z>-0.75 and walker.position.z<-0.4,"Fountain basin fails to contain player: " + str(walker.position))
	# Ordinary controller walking up/down the ramp and through the covered space.
	await place_at(Vector2(-18,8.5))
	await mouse(Vector2(640,400),true,false,MOUSE_BUTTON_RIGHT)
	await key(KEY_SHIFT,true)
	await walk_to(Vector2(-18,18))
	await key(KEY_SHIFT,false)
	await frames(10)
	var pavilion: Node3D = architecture.get_node("Pavilion")
	check(walker.is_on_floor() and absf(walker.position.y-pavilion.position.y)<0.03,"Pavilion is not walkably supported")
	var roof := root.world_3d.direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(walker.camera.global_position,walker.camera.global_position+Vector3.UP*8,1))
	check(not roof.is_empty() and roof.collider.is_in_group("village_architecture_collision"),"Pavilion does not cover its usable floor")
	if DisplayServer.get_name() != "headless":
		walker.camera.look_at(Vector3(0,1,-4))
		await capture("pavilion-covered.png")
		walker.camera.rotation = Vector3.ZERO
	await key(KEY_SHIFT,true)
	await walk_to(Vector2(-18,8.5))
	await key(KEY_SHIFT,false)
	await mouse(Vector2(640,400),false,false,MOUSE_BUTTON_RIGHT)
	await tap(KEY_HOME)
	await frames(15)
	check(walker.is_on_floor() and walker.position.distance_to(Vector3(0,0,5))<0.03,"Architecture obstructs Home spawn")
	await study.desktop_runtime.shutdown()
	print("VILLAGE_ARCHITECTURE_OK mode=",DisplayServer.get_name()," exteriors=3 landmark=1 pavilion=1 failures=",failures)
	quit(1 if failures else 0)
