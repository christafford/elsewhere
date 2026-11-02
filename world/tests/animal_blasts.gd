## Staged live-controller effects and actual input dispatch; not human acceptance.
extends SceneTree
var failures := 0
var scene: Node3D
var herd: Node3D
var actor: CharacterBody3D
var companion: CharacterBody3D
var camera: Camera3D
var output := "res://../.tools/animal-blasts"
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func frames(count: int) -> void:
	for i in range(count): await physics_frame
func capture(label: String) -> void:
	if DisplayServer.get_name()=="headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output.path_join(label+".png"))
func stage() -> void:
	actor.position = herd.navigation.surface(Vector2(3,6))
	companion.position = herd.navigation.surface(Vector2(6,6))
	actor.rotation.y = PI/2
	companion.rotation.y = -PI/2
	actor.velocity = Vector3.ZERO
	actor.path.clear()
	actor.remaining = 100
	actor.state = "rest"
	companion.path.clear()
	companion.velocity = Vector3.ZERO
	companion.remaining = 100
	companion.animate(1)
	camera.global_position = Vector3(6,2.6,11)
	camera.look_at(Vector3(4.5,.8,6))
func click(double := true) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.double_click = double
	event.position = camera.unproject_position(actor.global_position+Vector3.UP*.4)
	Input.parse_input_event(event)
	await process_frame
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await process_frame
func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	herd = scene.get_node("Animals")
	var deadline := Time.get_ticks_msec()+45000
	while not herd.initialized and Time.get_ticks_msec()<deadline: await physics_frame
	check(herd.initialized,"Animal initialization timed out")
	if not herd.initialized: quit(1); return
	if DisplayServer.get_name()=="headless":
		Engine.physics_ticks_per_second=240
		Engine.time_scale=4
	var player: CharacterBody3D = scene.get_node("Player")
	player.set_physics_process(false)
	player.position = Vector3(0,0,12)
	camera = player.get_node("Camera3D")
	for animal in herd.animals: animal.set_physics_process(false)
	actor = herd.animals.filter(func(a):return a.species=="dog")[0]
	companion = herd.animals.filter(func(a):return a.species=="dog")[1]
	actor.set_physics_process(true)
	# Every species must have two correctly resolved eyes and survive every effect.
	for species in ["dog","pig","chicken","goat","cow"]:
		actor.set_physics_process(false)
		actor = herd.animals.filter(func(a):return a.species==species)[0]
		actor.set_physics_process(true)
		for kind in range(4):
			stage()
			await frames(2)
			check(herd.start_blast(actor,camera.global_position-camera.global_basis.y*.4,kind),"Blast did not start")
			var effect: Node3D = actor.blast
			if effect==null: quit(1); return
			check(effect.target==companion,"Did not select nearest other animal")
			check(effect.eye_points.size()==2,"Missing authored eye anchors: "+species)
			check(not herd.start_blast(actor,Vector3.ZERO),"Repeated click stacked an effect")
			var initial_distance := actor.position.distance_to(companion.position)
			var max_lift := 0.0
			var contact := false
			var start_walked: float = actor.walked
			var duration: float = effect.DURATIONS[kind]
			for tick in range(ceili(duration*60)+3):
				await physics_frame
				max_lift = maxf(max_lift,actor.model.position.y)
				if is_instance_valid(effect): contact = contact or effect.contacted
				check(absf(actor.position.y-herd.navigation.sample_height.call(Vector2(actor.position.x,actor.position.z)))<.01,"Blast lost reserved ground support")
				if species=="dog" and tick in [11,35,83,155]: await capture("effect-%d-frame-%03d"%[kind,tick])
			check(not is_instance_valid(actor.blast),"Timed effect failed to end")
			check(absf(actor.model.position.y)<.05 and absf(actor.model.rotation.y)<.001 and absf(actor.model.rotation.z)<.001,"Stunt transform not restored")
			for part in actor.model.find_children("*","MeshInstance3D",true,false):
				check(float(part.get_instance_shader_parameter("char_amount"))==0,"Char leaked after effect")
			if kind in [1,3]:
				check(contact,"No companion interaction: %s/%d distance=%f"%[species,kind,actor.position.distance_to(companion.position)])
				check(actor.position.distance_to(companion.position)<initial_distance-.25,"No pursuit movement")
			if kind in [0,2]: check(max_lift>(2.0 if kind==2 else .6),"Aerial stunt missing")
			if kind==0: check(actor.walked>start_walked+.25,"Lightning did not cause a run")
			print("BLAST_CASE ",species," kind=",kind," contact=",contact," lift=",max_lift," travel=",actor.walked-start_walked)
			await capture("%s-%d-restored"%[species,kind])
		actor.position = actor.home
	# Input isolation and occlusion on the actual scene dispatch path.
	actor.set_physics_process(false)
	actor = herd.animals.filter(func(a):return a.species=="dog")[0]
	actor.set_physics_process(true)
	stage()
	await frames(2)
	var app: CanvasLayer = scene.application_mode
	app.host_focused = true # Explicit synthetic focus for the headless input fixture.
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await click(false)
	check(not is_instance_valid(actor.blast),"Single click triggered blast")
	app.set_process(false) # Keep synthetic ownership flags stable without a live client.
	for mode in ["app","help","launcher","unfocused","captured"]:
		if mode=="captured" and DisplayServer.get_name()=="headless": continue
		app.active = mode=="app"
		app.transition.running = mode=="app" # Synthetic mode has no client to route to.
		app.help_active = mode=="help"
		scene.app_launcher.opened = mode=="launcher"
		app.host_focused = mode!="unfocused"
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if mode=="captured" else Input.MOUSE_MODE_VISIBLE
		await click()
		check(not is_instance_valid(actor.blast),"Blast stole input in "+mode)
		if is_instance_valid(actor.blast): actor.blast.finish()
		await frames(1)
	app.transition.running=false
	app.active=false; app.help_active=false; scene.app_launcher.opened=false; app.host_focused=true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# An ordinary physical occluder blocks the ray.
	var wall := StaticBody3D.new()
	var collision := CollisionShape3D.new()
	var box := BoxShape3D.new(); box.size=Vector3(2,3,.4)
	collision.shape=box;wall.add_child(collision);scene.add_child(wall)
	wall.global_position=camera.global_position.lerp(actor.global_position+Vector3.UP*.4,.5)
	await frames(2)
	await click()
	check(not is_instance_valid(actor.blast),"Double click passed through wall")
	wall.queue_free();await frames(2)
	# Actual application housing blocks animal picking even on its reverse face.
	var objects: Node3D = scene.application_objects
	objects.set_process(false)
	var panel := preload("res://scripts/application_object.gd").new()
	objects.add_child(panel)
	panel.show()
	panel.global_position=camera.global_position.lerp(actor.global_position+Vector3.UP*.4,.5)
	panel.look_at(camera.global_position)
	objects.bindings[999]=panel # Explicit fixture only; no simulated client content.
	await frames(2)
	check(herd.pick_animal(camera.unproject_position(actor.global_position+Vector3.UP*.4))==null,"Animal picked through app housing")
	# A panel behind the animal must not steal its double click.
	panel.global_position=actor.global_position+Vector3.UP*.4+(actor.global_position+Vector3.UP*.4-camera.global_position).normalized()
	await frames(2)
	check(objects.pick(camera.unproject_position(actor.global_position+Vector3.UP*.4))==0,"Panel picked through animal")
	objects.bindings.erase(999)
	panel.queue_free()
	objects.set_process(true)
	await frames(2)
	await click()
	check(is_instance_valid(actor.blast),"World double click did not dispatch")
	if is_instance_valid(actor.blast): actor.blast.finish()
	await frames(2)
	# Random path is exercised repeatedly; all four choices must be reachable.
	var seen := {}
	herd.blast_rng.seed=4321
	for i in range(64):
		herd.start_blast(actor,Vector3.ZERO)
		seen[actor.blast.kind]=true
		actor.blast.finish()
		await frames(1)
	check(seen.size()==4,"Random choice omitted an outcome")
	# Missing companion is safe and still expires normally.
	var saved: Array[CharacterBody3D] = herd.animals.duplicate()
	herd.animals.assign([actor])
	for kind in [1,3]:
		herd.start_blast(actor,Vector3.ZERO,kind)
		check(actor.blast.target==null,"Solo animal targeted itself")
		await frames(305)
		check(not is_instance_valid(actor.blast),"Solo effect did not expire")
	herd.animals.assign(saved)
	check(actor.head.get_child_count()==0,"Temporary eyes or tongue leaked")
	await scene.desktop_runtime.shutdown()
	print("ANIMAL_BLASTS_OK mode=",DisplayServer.get_name()," failures=",failures)
	quit(1 if failures else 0)
