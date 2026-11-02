## Agent-run live-scene behavior and rendered evidence, not human acceptance.
extends SceneTree
const Landscape = preload("res://scripts/village_landscape.gd")
var failures := 0
var scene: Node3D
var herd: Node3D
var output := "res://../.tools/p22-t14"
var camera: Camera3D
var minimum_separation := INF
var max_ground_gap := 0.0
var max_foot_gap := 0.0

func _initialize() -> void:
	call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func frames(count: int) -> void:
	for i in range(count): await physics_frame
func capture(name: String) -> void:
	if DisplayServer.get_name()=="headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output.path_join(name+".png"))
func aim(animal: CharacterBody3D) -> void:
	var target: Vector3 = animal.global_position+Vector3.UP*(.35 if animal.species=="chicken" else .65)
	for angle in [0.0,PI*.5,PI,-PI*.5]:
		var offset := Vector3(2.7,1.0,3.3).rotated(Vector3.UP,angle)*(0.65 if animal.species=="chicken" else 1.0)
		var query := PhysicsRayQueryParameters3D.create(target,target+offset,1)
		if root.world_3d.direct_space_state.intersect_ray(query).is_empty():
			camera.position = target+offset
			camera.look_at(target)
			return
	check(false,"No unobstructed animal capture angle")
func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	herd = scene.get_node("Animals")
	var deadline := Time.get_ticks_msec()+45000
	while not herd.initialized and Time.get_ticks_msec()<deadline: await physics_frame
	check(herd.initialized,"Animal navigation did not initialize within 45 seconds")
	if not herd.initialized:
		quit(1)
		return
	check(herd.animals.size()==12,"Expected twelve animals, got %d"%herd.animals.size())
	print("ANIMAL_NAV build_ms=",herd.navigation.build_ms," nodes=",herd.navigation.graphs.map(func(g):return g.get_point_count()))
	var ids := {}
	for animal in herd.animals:
		check(not ids.has(animal.animal_id),"Duplicate stable animal ID")
		ids[animal.animal_id]=true
		check(animal.model!=null and animal.legs.size()>=2,"Missing articulated model")
		check(herd.navigation.outdoor(herd.navigation.surface(Vector2(animal.position.x,animal.position.z))),"Spawn not outdoors")
	camera = Camera3D.new()
	scene.add_child(camera)
	camera.current = true
	camera.fov=55
	# Render actual default population at its natural locations.
	for species in ["pig","chicken","dog","goat","cow"]:
		var animal: CharacterBody3D = herd.animals.filter(func(a): return a.species==species)[0]
		aim(animal)
		await frames(12)
		await capture(species+"-village")
	# Observe ninety seconds of simulated physics at the same 1/60s step. The
	# accelerated test is separately labeled; normal-speed frames follow below.
	Engine.physics_ticks_per_second=360
	Engine.time_scale=6
	var last_positions := {}
	var foraging_seen := {}
	var max_step := 0.0
	for i in range(5400):
		await physics_frame
		for animal in herd.animals:
			if last_positions.has(animal.animal_id): max_step=maxf(max_step,animal.position.distance_to(last_positions[animal.animal_id]))
			last_positions[animal.animal_id]=animal.position
		if i%60!=0: continue
		for animal in herd.animals:
			var xz := Vector2(animal.position.x,animal.position.z)
			if animal.state=="forage": foraging_seen[animal.species]=true
			check(Landscape.contains(xz,animal.radius*.65),"Animal escaped travel boundary: "+animal.animal_id)
			max_ground_gap=maxf(max_ground_gap,absf(animal.position.y-Landscape.height_at(xz)))
			max_foot_gap=maxf(max_foot_gap,animal.foot_gap)
			check(herd.navigation.outdoor(herd.navigation.surface(xz)),"Animal entered building/roof: "+animal.animal_id)
			for other in herd.animals:
				if animal==other:continue
				minimum_separation=minf(minimum_separation,animal.position.distance_to(other.position)/(animal.radius+other.radius))
	Engine.time_scale=1
	Engine.physics_ticks_per_second=60
	check(max_ground_gap<.16,"Animal lost terrain support: %f"%max_ground_gap)
	check(max_foot_gap<.045,"Foot placement missed terrain: %f"%max_foot_gap)
	check(max_step<.08,"Animal teleported or exceeded plausible speed: %f"%max_step)
	check(minimum_separation>.7,"Animals overlap body clearance: %f"%minimum_separation)
	for species in ["pig","chicken","dog","goat","cow"]:
		check(foraging_seen.has(species),"Species never selected natural foraging: "+species)
	for animal in herd.animals:
		print("ANIMAL_RESULT ",animal.animal_id," walked=",animal.walked," transitions=",animal.transitions," arrived=",animal.completed_routes," blocked=",animal.blocked_routes)
		check(animal.walked>2,"Animal never wandered: "+animal.animal_id)
		check(animal.transitions>2,"Animal never alternated activity: "+animal.animal_id)
		check(animal.completed_routes>0,"Animal never reached destination: "+animal.animal_id)
	# Player approach must cause a finite yielding response, without chasing.
	var dog: CharacterBody3D = herd.animals.filter(func(a):return a.species=="dog")[0]
	var player: CharacterBody3D = scene.get_node("Player")
	player.set_physics_process(false)
	player.position=dog.position+Vector3(1.5,0,0)
	var yields_before: int=dog.yielded
	dog.yield_cooldown=0
	await frames(240)
	check(dog.yielded>yields_before,"Animal did not yield to player approach")
	player.position=Vector3(0,0,5)
	# Four crossing routes through one clear square, with distinct body IDs.
	player.position=Vector3(0,0,-10)
	var crossing: Array = herd.animals.filter(func(a):return a.species in ["goat","dog"])
	var starts := [Vector3(2,0,4),Vector3(7,0,4),Vector3(2,0,10),Vector3(7,0,10)]
	var walked_before: Array[float] = []
	for i in range(crossing.size()):
		var animal: CharacterBody3D=crossing[i]
		animal.position=starts[i]+Vector3.UP*.025
		animal.velocity=Vector3.ZERO
		animal.follow(herd.navigation.route(starts[i],starts[3-i],animal.profile))
		walked_before.append(animal.walked)
	Engine.physics_ticks_per_second=360
	Engine.time_scale=6
	var crowd_separation:=INF
	for tick in range(1800):
		await physics_frame
		for a in crossing:
			for b in crossing:
				if a!=b: crowd_separation=minf(crowd_separation,a.position.distance_to(b.position)/(a.radius+b.radius))
	Engine.time_scale=1
	Engine.physics_ticks_per_second=60
	for i in range(crossing.size()):check(crossing[i].walked-walked_before[i]>3,"Crowded crossing deadlocked an animal")
	check(crowd_separation>.7,"Crowded crossing overlaps animals")
	print("ANIMAL_CROWD minimum_separation=",crowd_separation)
	# Normal-speed moving sequence: real scene, live gait, no forced pose.
	if DisplayServer.get_name()!="headless":
		for species in ["pig","chicken","dog","goat","cow"]:
			var animal: CharacterBody3D=herd.animals.filter(func(a):return a.species==species)[0]
			animal.remaining=0
			var moving_deadline:=Time.get_ticks_msec()+20000
			while animal.travel_speed<.1 and Time.get_ticks_msec()<moving_deadline: await physics_frame
			check(animal.travel_speed>=.1,"No moving capture for "+species)
			for step in range(12):
				aim(animal)
				await frames(10)
				await capture("%s-motion-%02d"%[species,step])
		# Separate art fixtures: explicitly staged forage poses on clear grass.
		# Natural state selection was asserted above; these are not wander evidence.
		herd.set_physics_process(false)
		for species in ["pig","chicken","dog","goat","cow"]:
			var animal: CharacterBody3D=herd.animals.filter(func(a):return a.species==species)[0]
			var graph: AStar3D=herd.navigation.graphs[animal.profile]
			var nearest:=INF
			var pose:=animal.position
			for id in graph.get_point_ids():
				var p:=graph.get_point_position(id)
				if herd.grass_at(p) and p.distance_to(animal.home)<nearest and herd.navigation.clear_at(p,animal.profile,true,[animal.get_rid()]):
					pose=p;nearest=p.distance_to(animal.home)
			check(nearest<INF,"No clear grass for forage art fixture")
			animal.position=pose
			animal.path.clear();animal.velocity=Vector3.ZERO
			animal.state="forage";animal.remaining=10
			await frames(90)
			aim(animal)
			await capture(species+"-forage-pose")
	print("ANIMAL_METRICS max_gap=",max_ground_gap," foot_gap=",max_foot_gap," max_step=",max_step," minimum_separation=",minimum_separation," path_requests=",herd.navigation.path_requests)
	await scene.desktop_runtime.shutdown()
	print("VILLAGE_ANIMALS_OK seed=",herd.seed_value," mode=",DisplayServer.get_name()," failures=",failures)
	quit(1 if failures else 0)
