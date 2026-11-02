## One ambient animal: physical travel, bounded decisions, distance-driven joints.
extends CharacterBody3D

var animal_id := ""
var species := ""
var spec: Dictionary
var herd: Node3D
var rng := RandomNumberGenerator.new()
var model: Node3D
var head: Node3D
var head_rest := Vector3.ZERO
var tail: Node3D
var legs: Array[Node3D] = []
var shins: Array[Node3D] = []
var path := PackedVector3Array()
var waypoint := 0
var state := "rest"
var remaining := 1.0
var decision_due := false
var phase := 0.0
var age := 0.0
var walked := 0.0
var stalled := 0.0
var yield_cooldown := 0.0
var feeding := 0.0
var gait := 0.0
var transitions := 0
var completed_routes := 0
var blocked_routes := 0
var yielded := 0
var travel_speed := 0.0
var home := Vector3.ZERO
var leg_origins: Array[Vector3] = []
var foot_gap := 0.0
var profile: int:
	get: return int(spec.profile)
var radius: float:
	get: return herd.navigation.RADII[profile]

func _ready() -> void:
	collision_layer = 16
	collision_mask = 23
	# Terrain support is sampled from the same authored surface validated by
	# navigation. Sweeping twelve wide bodies against its dense triangle mesh
	# dominated physics time; keep physical sweeps for obstacles and actors.
	motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	for ground in herd.navigation.ground_rids:
		PhysicsServer3D.body_add_collision_exception(get_rid(),ground)
	var collision := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = radius*.72
	shape.height = {"cow":1.4,"goat":1.0,"pig":.7,"dog":.7,"chicken":.6}[species]
	collision.shape = shape
	collision.position.y = shape.height*.5
	add_child(collision)
	model = herd.Models[species].instantiate()
	add_child(model)
	herd.apply_coats(model)
	head = model.find_child("Head",true,false)
	head_rest = head.position
	tail = model.find_child("Tail",true,false)
	for i in range(2 if species=="chicken" else 4):
		legs.append(model.find_child("Leg%d" % i,true,false))
		shins.append(model.find_child("Shin%d" % i,true,false))
		leg_origins.append(legs[-1].position)
	remaining = rng.randf_range(.7,3.5)
	phase = rng.randf()*TAU
	age = rng.randf()*10
	rotation.y = rng.randf()*TAU

func pause(blocked := false) -> void:
	path.clear()
	waypoint = 0
	state = "rest" if blocked or rng.randf()<.25 else "forage"
	if species in ["cow","goat"] and not herd.grass_at(position): state="rest"
	remaining = rng.randf_range(1.5,4) if blocked else rng.randf_range(spec.pause[0],spec.pause[1])
	decision_due = false
	stalled = 0
	transitions += 1
	if blocked: blocked_routes += 1

func follow(route: PackedVector3Array, yielding := false) -> void:
	if route.size()<2:
		pause(true)
		return
	path = route
	waypoint = 1
	state = "yield" if yielding else "walk"
	decision_due = false
	stalled = 0
	transitions += 1
	if yielding:
		yielded += 1
		yield_cooldown = 4

func _physics_process(delta: float) -> void:
	if not herd.navigation.ready_for_paths: return
	age += delta
	yield_cooldown = maxf(0,yield_cooldown-delta)
	remaining -= delta
	if path.is_empty() and remaining<=0: decision_due=true
	var desired := Vector3.ZERO
	if not path.is_empty():
		while waypoint<path.size() and Vector2(path[waypoint].x-position.x,path[waypoint].z-position.z).length()<.22:
			waypoint += 1
		if waypoint>=path.size():
			completed_routes += 1
			pause()
		else:
			desired = (path[waypoint]-position)*Vector3(1,0,1)
			desired = desired.normalized()
			desired *= float(spec.speed)*(1.25 if state=="yield" else 1.0)
			desired = herd.steer(self,desired)
			if desired.length_squared()>.001:
				var target_yaw := atan2(desired.x,desired.z)
				rotation.y = rotate_toward(rotation.y,target_yaw,delta*(1.8 if species=="cow" else 3.0))
				var facing := Vector3(sin(rotation.y),0,cos(rotation.y))
				desired = facing*desired.length()*maxf(0,facing.dot(desired.normalized()))
	var flat := Vector3(velocity.x,0,velocity.z).move_toward(desired,delta*1.8)
	# Check the swept clearance before travel; local avoidance cannot cut walls,
	# boundary corners or graph exclusion zones. A blocked animal decelerates/stops.
	var next := position+flat*delta
	next.y = herd.navigation.sample_height.call(Vector2(next.x,next.z))
	var at := position
	at.y = herd.navigation.sample_height.call(Vector2(at.x,at.z))
	if flat.length_squared()>.00001 and not herd.navigation.segment_clear(at,next,profile,true,[get_rid()]): flat=Vector3.ZERO
	if flat==Vector3.ZERO: next=at
	velocity.x = flat.x
	velocity.z = flat.z
	velocity.y = (next.y-position.y)/maxf(delta,.001)
	var before := position
	if velocity.length_squared()>.000001: move_and_slide()
	var floor_y: float = herd.navigation.sample_height.call(Vector2(position.x,position.z))
	if position.y!=floor_y: position.y=floor_y
	var distance := Vector2(position.x-before.x,position.z-before.z).length()
	travel_speed = distance/maxf(delta,.001)
	walked += distance
	phase += distance/float(spec.stride)*TAU
	if not path.is_empty():
		stalled = stalled+delta if travel_speed<.04 else 0.0
		if stalled>1.8: pause(true)
	animate(delta)

func animate(delta: float) -> void:
	gait = move_toward(gait,clampf(travel_speed/float(spec.speed),0,1.25),delta*5)
	feeding = move_toward(feeding,1.0 if state=="forage" else 0.0,delta*.85)
	var nod := sin(age*(6.0 if species=="chicken" else 1.7))
	# Pecking folds the neck down as well as rotating the head; a head-only
	# rotation leaves the beak well above the ground.
	if species=="chicken": head.position=head_rest+Vector3(0,-.24,.08)*feeding
	var bend: float = {"cow":1.1,"goat":1.05,"pig":.75,"dog":.85,"chicken":1.15}[species]
	head.rotation.x = feeding*(bend+nod*.08)+sin(phase)*.025*gait
	head.rotation.y = sin(age*.7)*.08*(1-feeding)
	tail.rotation.y = sin(age*(4 if species=="dog" else 1.6))*(.25 if species=="dog" else .09)
	# Follow the local ground slope, bounded to avoid an unstable body on rough soil.
	var forward := Vector2(sin(rotation.y),cos(rotation.y))*.25
	var xz := Vector2(position.x,position.z)
	var pitch := atan2(herd.navigation.sample_height.call(xz+forward)-herd.navigation.sample_height.call(xz-forward),.5)
	model.rotation.x = lerpf(model.rotation.x,clampf(-pitch,-.25,.25),minf(1,delta*5))
	# Align the visual body to the authoritative ground, then solve each
	# two-joint leg against the terrain beneath that individual foot.
	model.position.y = herd.navigation.sample_height.call(xz)-position.y+.015
	foot_gap = 0
	for i in range(legs.size()): plant_foot(i)

func plant_foot(i: int) -> void:
	var leg := legs[i]
	var shin := shins[i]
	var length: float = {"cow":.78,"goat":.58,"pig":.31,"dog":.42,"chicken":.23}[species]
	var endpoint := Vector3(0,-length*.48+.03,.045)
	var sole := .06 if species=="cow" else .0375
	if species=="chicken":
		endpoint = Vector3(0,-.115,.015)
		sole = .006
	var offset: float = [0.0,PI,PI*.5,PI*1.5][i] if species!="chicken" else i*PI
	var cycle := fposmod((phase+offset)/TAU,1.0)
	var stride: float = float(spec.stride)*.65*gait
	var z := lerpf(stride*.5,-stride*.5,cycle/.65) if cycle<.65 else lerpf(-stride*.5,stride*.5,smoothstep(.65,1,cycle))
	var lift := 0.0 if cycle<.65 else sin((cycle-.65)/.35*PI)*(.055 if species=="chicken" else .09)*gait
	leg.position = leg_origins[i]
	var target := model.to_global(leg.position+Vector3(0,-length,z))
	target.y = herd.navigation.sample_height.call(Vector2(target.x,target.z))+sole+lift
	var relative := model.to_local(target)-leg.position
	var upper := shin.position.length()
	var lower := endpoint.length()
	var reach := clampf(Vector2(relative.y,relative.z).length(),absf(upper-lower)+.001,upper+lower-.001)
	var direction := atan2(-relative.z,-relative.y)
	var angle := acos(clampf((upper*upper+reach*reach-lower*lower)/(2*upper*reach),-1,1))
	var knee := PI-acos(clampf((upper*upper+lower*lower-reach*reach)/(2*upper*lower),-1,1))
	var upper_rest := atan2(-shin.position.z,-shin.position.y)
	var lower_rest := atan2(-endpoint.z,-endpoint.y)
	leg.rotation.x = direction+angle-upper_rest
	shin.rotation.x = -knee+upper_rest-lower_rest
	# Small extension correction handles terrain across the body width; the hip
	# remains inside its shoulder/haunch rather than leaving hooves suspended.
	var actual := shin.to_global(endpoint)
	leg.position.y += clampf(target.y-actual.y,-.12,.12)
	foot_gap = maxf(foot_gap,absf(shin.to_global(endpoint).y-target.y))
