## Location-owned ambient life. No desktop IDs, compositor or persistence.
extends Node3D

const Landscape = preload("res://scripts/village_landscape.gd")
const Navigation = preload("res://scripts/animal_navigation.gd")
const Animal = preload("res://scripts/village_animal.gd")
const Models = {
	"pig": preload("res://art/animals/pig.glb"),
	"chicken": preload("res://art/animals/chicken.glb"),
	"dog": preload("res://art/animals/dog.glb"),
	"goat": preload("res://art/animals/goat.glb"),
	"cow": preload("res://art/animals/cow.glb"),
}
const Blast = preload("res://scripts/animal_blast.gd")
var blast_rng := RandomNumberGenerator.new()
var navigation: Node3D
var animals: Array[CharacterBody3D] = []
var player: CharacterBody3D
var initialized := false
var cursor := 0
var seed_value := 2214
var population: Dictionary
var coats: Dictionary = {}

func grass_at(p: Vector3) -> bool:
	return (absf(p.x)>13 or absf(p.z)>11) and Landscape.route_distance(Vector2(p.x,p.z))>2.4

func apply_coats(model: Node3D) -> void:
	for mesh in model.find_children("*","MeshInstance3D",true,false):
		for surface in range(mesh.mesh.get_surface_count()):
			var original: StandardMaterial3D = mesh.mesh.surface_get_material(surface)
			var key: String = original.resource_name
			if not coats.has(key):
				var material := ShaderMaterial.new()
				material.shader = preload("res://scripts/animal_coat.gdshader")
				material.set_shader_parameter("coat",original.albedo_color)
				material.set_shader_parameter("roughness_value",original.roughness)
				coats[key] = material
			mesh.set_surface_override_material(surface,coats[key])

func _ready() -> void:
	blast_rng.randomize()
	if "--no-animals" in OS.get_cmdline_user_args(): return
	population = JSON.parse_string(FileAccess.get_file_as_string("res://art/animals/population.json"))
	seed_value = int(population.seed)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--animal-seed="): seed_value=int(arg.get_slice("=",1))
	call_deferred("initialize")

func initialize() -> void:
	player = get_parent().get_node("Player")
	navigation = Navigation.new()
	navigation.name = "Navigation"
	add_child(navigation)
	await get_tree().physics_frame
	var ground: Array[RID] = []
	for body in get_parent().get_node("Landscape/Ground").find_children("*","StaticBody3D",true,false): ground.append(body.get_rid())
	if ground.is_empty():
		push_error("Animal navigation needs the location's physical ground")
		return
	navigation.setup(PackedVector2Array(Landscape.BOUNDARY),Landscape.height_at,ground)
	await navigation.rebuild()
	for species in population.species:
		var spec: Dictionary = population.species[species]
		var rng := RandomNumberGenerator.new()
		rng.seed = seed_value + species.hash()
		var home: Vector3 = navigation.surface(Vector2(spec.home[0],spec.home[1]))
		var graph: AStar3D = navigation.graphs[int(spec.profile)]
		var closest := graph.get_closest_point(home)
		if closest<0:
			push_error("No outdoor navigation for animal species: "+species)
			continue
		home = graph.get_point_position(closest)
		for i in range(int(spec.count)):
			var spawn := Vector3.INF
			for attempt in range(80):
				var id := graph.get_closest_point(home+Vector3(rng.randf_range(-4,4),0,rng.randf_range(-4,4)))
				var p := graph.get_point_position(id)
				if graph.get_point_connections(id).is_empty() or not navigation.clear_at(p,int(spec.profile),true): continue
				var occupied := false
				for other in animals:
					if p.distance_to(other.position)<Navigation.RADII[int(spec.profile)]+other.radius+.5: occupied=true
				if not occupied:
					spawn=p
					break
			if spawn==Vector3.INF:
				push_warning("No clear spawn for %s/%d; population not forced" % [species,i])
				continue
			var animal := Animal.new()
			animal.species = species
			animal.animal_id = "village-animal-%s-%02d" % [species,i+1]
			animal.name = animal.animal_id
			animal.spec = spec
			animal.herd = self
			animal.home = home
			animal.rng.seed = rng.randi()
			animal.position = spawn+Vector3.UP*.025
			add_child(animal)
			animals.append(animal)
			# Spread scene instantiation/first rendering over startup frames too.
			await get_tree().process_frame
	initialized = true

func _physics_process(_delta: float) -> void:
	if not initialized or animals.is_empty() or not navigation.ready_for_paths: return
	# At most one animal decision/path request per physics tick, independently of
	# population. Movement and joint animation remain smooth at physics rate.
	cursor = (cursor+1)%animals.size()
	var animal: CharacterBody3D = animals[cursor]
	if is_instance_valid(animal.blast):
		animal.blast.plan()
		return
	var away: Vector3 = (animal.position-player.position)*Vector3(1,0,1)
	if away.length()<animal.radius+1.5 and animal.yield_cooldown<=0:
		choose_route(animal,away.normalized())
	elif animal.decision_due:
		choose_route(animal)

func choose_route(animal: CharacterBody3D, away := Vector3.ZERO) -> void:
	var graph: AStar3D = navigation.graphs[animal.profile]
	var target := Vector3.INF
	var best := -INF
	var start := animal.position
	start.y = navigation.sample_height.call(Vector2(start.x,start.z))
	var center: Vector3 = animal.home
	# Cohesion follows companions rather than prescribing a synchronized route.
	var companions := 1
	for other in animals:
		if other!=animal and other.species==animal.species:
			center += other.position
			companions += 1
	center /= companions
	for attempt in range(14):
		var angle: float = animal.rng.randf()*TAU
		var reach: float = animal.rng.randf_range(1.5,float(animal.spec.roam))
		var desired: Vector3 = start+Vector3(sin(angle),0,cos(angle))*reach
		if away!=Vector3.ZERO: desired=start+away*4+Vector3(sin(angle),0,cos(angle))*2
		var id := graph.get_closest_point(desired)
		if id<0: continue
		var p := graph.get_point_position(id)
		if p.distance_to(start)<1.1 or not navigation.clear_at(p,animal.profile,true,[animal.get_rid()]): continue
		var score: float = animal.rng.randf()*3 - p.distance_to(center)*(.02 if animal.species=="dog" else .18)
		if animal.spec.grass and grass_at(p): score += 3
		if away!=Vector3.ZERO: score += (p-start).normalized().dot(away)*8
		if score>best:
			best=score
			target=p
	if target==Vector3.INF:
		animal.pause(true)
		return
	animal.follow(navigation.route(start,target,animal.profile),away!=Vector3.ZERO)

func steer(animal: CharacterBody3D, desired: Vector3) -> Vector3:
	if desired.length_squared()<.001: return desired
	var separation := Vector3.ZERO
	for other in animals:
		if other==animal: continue
		var away := (animal.position-other.position)*Vector3(1,0,1)
		var safe: float = animal.radius+other.radius+.6
		if away.length()<safe:
			separation += away.normalized()*(1-away.length()/safe)*2
	var away := (animal.position-player.position)*Vector3(1,0,1)
	if away.length()<animal.radius+1.5: separation += away.normalized()*1.5
	var direction := (desired.normalized()+separation).normalized()
	var start: Vector3 = navigation.surface(Vector2(animal.position.x,animal.position.z))
	# Try a small set of forward alternatives around transient objects. If all
	# are occupied, stop and let the bounded stall/replan timer take over.
	for angle in [0.0,.5,-.5,1.0,-1.0]:
		var option := direction.rotated(Vector3.UP,angle)
		var reach := .7
		if animal.waypoint<animal.path.size(): reach=minf(reach,animal.position.distance_to(animal.path[animal.waypoint]))
		var point: Vector3 = navigation.surface(Vector2(start.x+option.x*reach,start.z+option.z*reach))
		if navigation.segment_clear(start,point,animal.profile,true,[animal.get_rid()]): return option*desired.length()
	return Vector3.ZERO


func nearest_companion(animal: CharacterBody3D) -> CharacterBody3D:
	var result: CharacterBody3D
	var distance := INF
	for other in animals:
		if not is_instance_valid(other) or other == animal: continue
		var candidate := animal.position.distance_squared_to(other.position)
		if candidate < distance:
			distance = candidate
			result = other
	return result

func start_blast(animal: CharacterBody3D, origin: Vector3, kind := -1) -> bool:
	if not initialized or not is_instance_valid(animal) or not animals.has(animal) or is_instance_valid(animal.blast): return false
	if kind < -1 or kind > 3: return false
	var effect := Blast.new()
	effect.animal = animal
	effect.target = nearest_companion(animal)
	effect.kind = blast_rng.randi_range(0,3) if kind == -1 else kind
	effect.source = origin
	animal.blast = effect
	animal.add_child(effect)
	return true

func pick_animal(pointer: Vector2) -> CharacterBody3D:
	var objects: Node3D = get_parent().application_objects
	var camera: Camera3D = objects.camera
	var origin := camera.project_ray_origin(pointer)
	var direction := camera.project_ray_normal(pointer)
	var query := PhysicsRayQueryParameters3D.create(origin,origin+direction*20,1|2|16)
	query.exclude = [player.get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty() or not hit.collider is CharacterBody3D or not animals.has(hit.collider): return null
	var distance := origin.distance_to(hit.position)
	for panel in objects.bindings.values():
		if panel.occlusion_distance(origin,direction) < distance: return null
	return hit.collider

func _unhandled_input(event: InputEvent) -> void:
	if not initialized or not event is InputEventMouseButton: return
	if event.button_index != MOUSE_BUTTON_LEFT or not event.pressed or not event.double_click: return
	var desktop: Node = get_parent().desktop_runtime
	var app: CanvasLayer = desktop.application_mode
	if app.active or app.help_active or desktop.app_launcher.opened or not app.host_focused: return
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED or desktop.application_objects.has_grab(): return
	var animal := pick_animal(event.position)
	if animal == null: return
	var camera: Camera3D = desktop.application_objects.camera
	start_blast(animal,camera.global_position-camera.global_basis.y*.3+camera.global_basis.x*.25)
	get_viewport().set_input_as_handled()
