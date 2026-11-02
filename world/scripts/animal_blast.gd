## A bounded cartoon interruption; no damage, breeding, or persistent state.
## Ground collision stays reserved during aerial stunts so landing is always safe.
extends Node3D

const DURATIONS := [1.8, 5.0, 3.4, 5.0]
const COLORS := [Color("aeeeff"), Color("ff321b"), Color("c5ece6"), Color("ff79be")]
var animal: CharacterBody3D
var target: CharacterBody3D
var kind := 0
var elapsed := 0.0
var replan := 0.0
var source := Vector3.ZERO
var contacted := false
var mesh := ImmediateMesh.new()
var ink: ShaderMaterial
var drawing: MeshInstance3D
var eyes: Array[MeshInstance3D] = []
var hearts: Array[MeshInstance3D] = []
var tongue: MeshInstance3D
var head_rest_rotation := Vector3.ZERO
var model_rest := Transform3D.IDENTITY
var coat_meshes: Array[MeshInstance3D] = []
var eye_points: Array[Vector3] = []
var mouth := Vector3.ZERO

func _ready() -> void:
	model_rest = animal.model.transform
	head_rest_rotation = animal.head.rotation
	for part in animal.model.find_children("*", "MeshInstance3D", true, false):
		coat_meshes.append(part)
	# Read eye centers from the authored eye surface, including every species' neck.
	var head_meshes: Array[Node] = animal.head.find_children("*", "MeshInstance3D", true, false)
	if animal.head is MeshInstance3D: head_meshes.append(animal.head)
	for part in head_meshes:
		for surface in range(part.mesh.get_surface_count()):
			if part.mesh.surface_get_material(surface).resource_name != "eye": continue
			var vertices: PackedVector3Array = part.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]
			for side in [-1,1]:
				var center := Vector3.ZERO
				var count := 0
				for vertex in vertices:
					if vertex.x * side > 0:
						center += animal.head.to_local(part.to_global(vertex))
						count += 1
				if count: eye_points.append(center/count)
	mouth = {"pig":Vector3(0,-.19,.54),"cow":Vector3(0,.06,.92),"dog":Vector3(0,.16,.61),"goat":Vector3(0,.16,.61),"chicken":Vector3(0,.10,.18)}[animal.species]
	ink = ShaderMaterial.new()
	ink.shader = preload("res://scripts/blast_ribbon.gdshader")
	drawing = MeshInstance3D.new()
	drawing.mesh = mesh
	drawing.material_override = ink
	drawing.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(drawing)
	if kind == 0:
		for part in coat_meshes: part.set_instance_shader_parameter("char_amount",1.0)
	if kind == 1:
		for point in eye_points:
			var eye := orb(.045 if animal.species != "chicken" else .027, COLORS[1])
			animal.head.add_child(eye)
			eye.position = point
			eyes.append(eye)
	if kind == 3:
		var material := ShaderMaterial.new()
		material.shader = preload("res://scripts/heart_smoke.gdshader")
		for i in range(14):
			var heart := MeshInstance3D.new()
			var quad := QuadMesh.new()
			quad.size = Vector2.ONE
			heart.mesh = quad
			heart.material_override = material
			heart.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			add_child(heart)
			hearts.append(heart)
		tongue = orb(.06,Color("ff8aa1"))
		animal.head.add_child(tongue)
		tongue.hide()
	animal.path.clear()
	animal.velocity = Vector3.ZERO
	animal.state = "rest"
	animal.feeding = 0

func orb(radius: float, color: Color) -> MeshInstance3D:
	var result := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius*2
	sphere.radial_segments = 12
	sphere.rings = 6
	result.mesh = sphere
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 2
	result.material_override = material
	result.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return result

func tick(delta: float) -> bool:
	elapsed += delta
	replan -= delta
	if elapsed >= DURATIONS[kind]:
		finish()
		return false
	animal.model.rotation.y = model_rest.basis.get_euler().y
	animal.model.rotation.z = model_rest.basis.get_euler().z
	animal.remaining = 1
	animal.decision_due = false
	animal.state = "walk" if not animal.path.is_empty() else "rest"
	return true

func plan() -> void:
	if replan > 0 or kind == 2: return
	replan = .55
	if kind == 0:
		animal.herd.choose_route(animal)
		return
	if not is_instance_valid(target):
		animal.path.clear()
		return
	var away: Vector3 = animal.position-target.position
	var spacing: float = animal.radius+target.radius+.3
	if away.length() <= spacing+.4:
		animal.path.clear()
		return
	# Sample a ring outside the companion's clearance, then use the same outdoor
	# paths and swept collision as ordinary wandering. Never run through a wall.
	var best := INF
	var destination := Vector3.INF
	for i in range(12):
		var direction := away.normalized().rotated(Vector3.UP,i*TAU/12)
		var point: Vector3 = target.position+direction*(spacing+.25)
		point = animal.herd.navigation.surface(Vector2(point.x,point.z))
		if not animal.herd.navigation.clear_at(point,animal.profile,true,[animal.get_rid()]): continue
		var distance := animal.position.distance_to(point)
		if distance < best:
			best = distance
			destination = point
	if destination != Vector3.INF:
		var route: PackedVector3Array = animal.herd.navigation.route(animal.position,destination,animal.profile)
		if not route.is_empty() and animal.herd.navigation.segment_clear(route[-1],destination,animal.profile,true,[animal.get_rid()]):
			route.append(destination)
			animal.follow(route)

func present() -> void:
	var center: Vector3 = animal.global_position+Vector3.UP*.5
	var fade := minf(1,(DURATIONS[kind]-elapsed)*3)
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	if kind == 0:
		animal.model.position.y += sin(clampf(elapsed/.6,0,1)*PI)*.85
		if elapsed < .42:
			var previous := center+Vector3.UP*9
			for i in range(1,13):
				var next := center+Vector3(sin(i*7.4+floor(elapsed*24))*.35,9*(1-i/12.0),cos(i*4.2)*.22)
				if i==12: next=center
				tube(previous,next,.045,COLORS[0])
				tube(previous,next,.12,Color(.3,.7,1,.15))
				previous=next
		for part in coat_meshes: part.set_instance_shader_parameter("char_amount",fade)
	elif kind == 2:
		var lift := smoothstep(.2,1.0,elapsed)*(1-smoothstep(2.5,3.35,elapsed))
		animal.model.position += Vector3(sin(elapsed*9)*.22,2.5,cos(elapsed*9)*.22)*lift
		animal.model.rotation.y = elapsed*12*lift
		animal.model.rotation.z = sin(elapsed*8)*.25*lift
		# Three tapered helical wind ribbons descend, lift, then dissipate.
		center.y -= .45
		var descent := (1-smoothstep(0,.65,elapsed))*7
		funnel(center+Vector3.UP*descent,fade)
		for strand in range(3):
			var previous := Vector3.ZERO
			for i in range(65):
				var h := i/64.0
				var angle := h*TAU*3-elapsed*11+strand*TAU/3
				var r := .22+h*1.1
				var point := center+Vector3(cos(angle)*r,h*3.8+descent,sin(angle)*r)
				if i: tube(previous,point,.018+h*.03,Color(.5,.72,.69,.36*fade))
				previous=point
	else:
		if is_instance_valid(tongue): tongue.hide()
		var head_center: Vector3 = animal.head.global_position
		if elapsed < 1:
			var color: Color = COLORS[kind]
			color.a = sin(elapsed*PI)
			tube(source,head_center,.045,color)
			tube(source,head_center,.11,Color(color,.15*color.a))
		if is_instance_valid(target):
			var to: Vector3 = target.global_position+Vector3.UP*(.35 if target.species=="chicken" else .65)
			var spacing: float = animal.radius+target.radius+.75
			if animal.position.distance_to(target.position) < spacing:
				animal.rotation.y = rotate_toward(animal.rotation.y,atan2(to.x-animal.global_position.x,to.z-animal.global_position.z),.12)
				var ray := PhysicsRayQueryParameters3D.create(head_center,to,1|4)
				if animal.get_world_3d().direct_space_state.intersect_ray(ray).is_empty():
					contacted = true
					if kind == 1 and elapsed > .8:
						for point in eye_points: flame(animal.head.to_global(point),to,fade)
					elif kind == 3:
						animal.head.rotation.x = -.12+sin(elapsed*15)*.09
						tongue.show()
						tongue.position = mouth+Vector3(0,0,.12)
						tongue.scale = Vector3(.65,.32,1.5+sin(elapsed*15)*.8)
		if kind == 3: present_hearts(head_center,fade)
	# ImmediateMesh does not accept an empty surface.
	tube(center,center+Vector3.UP*.001,.0001,Color(0,0,0,0))
	mesh.surface_end()

func flame(from: Vector3, to: Vector3, fade: float) -> void:
	var previous := from
	for i in range(1,13):
		var t := i/12.0
		var point := from.lerp(to,t)+Vector3(sin(t*22-elapsed*30),sin(t*18-elapsed*24),cos(t*27-elapsed*30))*.12*t
		tube(previous,point,(.025+.08*t)*(1+.25*sin(elapsed*32+i)),Color(1,.24+.4*(1-t),.025,fade))
		previous=point

func present_hearts(center: Vector3, fade: float) -> void:
	for i in range(hearts.size()):
		var heart := hearts[i]
		var t := fposmod(elapsed*.8+i/14.0,1.0)
		if elapsed < 1.5:
			heart.global_position = source.lerp(center,t)+Vector3(sin(i*7.0)*.22,elapsed*.25+sin(i*3.0)*.15,cos(i*5.0)*.2)
		else:
			heart.global_position = center+Vector3(sin(i*7.0+elapsed)*.65,t*1.5+.35,cos(i*5.0+elapsed)*.65)
		heart.scale = Vector3.ONE*(.24+.22*sin(t*PI))
		heart.set_instance_shader_parameter("opacity",sin(t*PI)*fade*.8)
		heart.set_instance_shader_parameter("smoke_age",t)

func tube(a: Vector3, b: Vector3, width: float, color: Color) -> void:
	var direction := (b-a).normalized()
	var side := direction.cross(Vector3.UP).normalized()
	if side.length_squared()<.01: side=Vector3.RIGHT
	var up := direction.cross(side).normalized()
	for axis in [side,up]:
		mesh.surface_set_color(color)
		var vertices := [a-axis*width,b-axis*width,b+axis*width,a-axis*width,b+axis*width,a+axis*width]
		var uv := [Vector2(0,0),Vector2(0,1),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(1,0)]
		for i in range(6):
			mesh.surface_set_uv(uv[i])
			mesh.surface_add_vertex(to_local(vertices[i]))

func finish() -> void:
	for part in coat_meshes:
		if is_instance_valid(part): part.set_instance_shader_parameter("char_amount",0.0)
	for eye in eyes:
		if is_instance_valid(eye): eye.queue_free()
	if is_instance_valid(tongue): tongue.queue_free()
	animal.model.transform = model_rest
	animal.head.rotation = head_rest_rotation
	animal.blast = null
	animal.velocity = Vector3.ZERO
	animal.pause()
	queue_free()


func funnel(center: Vector3, fade: float) -> void:
	for layer in range(16):
		var low := layer/16.0
		var high := (layer+1)/16.0
		for segment in range(32):
			var a := segment*TAU/32+elapsed*2
			var b := (segment+1)*TAU/32+elapsed*2
			var points := []
			for pair in [Vector2(a,low),Vector2(b,low),Vector2(b,high),Vector2(a,low),Vector2(b,high),Vector2(a,high)]:
				var radius: float = .22+pair.y*1.1
				points.append(center+Vector3(cos(pair.x)*radius,pair.y*3.8,sin(pair.x)*radius))
			mesh.surface_set_color(Color(.55,.74,.71,.09*fade*sin((low+.03)*PI)))
			for i in range(6):
				mesh.surface_set_uv(Vector2(.5,0))
				mesh.surface_add_vertex(to_local(points[i]))
