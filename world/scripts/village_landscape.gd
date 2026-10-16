## P22-T03: one authored site, in meters. No random terrain or runtime services.
extends Node3D

const Lanes = preload("res://scripts/village_lanes.gd")

const HALF_GROUND := 48.0
const GRID_STEP := 0.5
# Clockwise as seen from above; x/z coordinates. The inner foot of the bank
# defines the playable boundary (84m across), not an invisible collision box.
const BOUNDARY := [Vector2(-30,-42), Vector2(20,-42), Vector2(38,-30), Vector2(42,-10), Vector2(40,22), Vector2(28,40), Vector2(-12,42), Vector2(-34,32), Vector2(-42,10), Vector2(-40,-22)]
const CRESTS := [3.8, 3.4, 2.8, 2.6, 2.6, 2.8, 3.0, 3.8, 4.2, 4.2]
# Four deliberately different approaches; endpoints are turnarounds inside the
# bank. Curved joins come from the distance to these fixed centerline segments.
const ROUTES := {
	"south_approach": [Vector2(0,10), Vector2(0,16), Vector2(-2,22), Vector2(-6,28), Vector2(-8,34), Vector2(-8,37)],
	"west_rise": [Vector2(-12,0), Vector2(-18,0), Vector2(-24,-3), Vector2(-28,-9), Vector2(-31,-16)],
	"north_saddle": [Vector2(0,-10), Vector2(0,-16), Vector2(3,-22), Vector2(6,-28), Vector2(5,-35)],
	"east_shelf": [Vector2(12,0), Vector2(18,0), Vector2(24,3), Vector2(28,8), Vector2(32,14)],
}
const PATH_HALF_WIDTH := 2.0
# Height control lattice, west to east in each row, north to south. Smooth
# interpolation joins the authored rises; the central square is graded flat.
const HEIGHTS := [
	[3.8, 3.8, 3.2, 2.7, 2.5, 2.0, 1.8],
	[3.6, 3.2, 2.4, 1.8, 1.7, 1.4, 1.6],
	[3.2, 2.7, 1.2, 0.6, 0.7, 1.0, 1.5],
	[2.6, 2.2, 0.8, 0.0, 0.4, 0.8, 1.3],
	[2.1, 1.6, 0.7, 0.3, 0.5, 0.9, 1.3],
	[1.8, 1.3, 0.9, 0.8, 1.0, 1.3, 1.5],
	[1.8, 1.6, 1.3, 1.2, 1.3, 1.6, 1.8],
]

static func height_at(p: Vector2) -> float:
	var cell := ((p + Vector2.ONE * HALF_GROUND) / 16.0).clamp(Vector2.ZERO, Vector2.ONE * 5.99999)
	var x := int(cell.x)
	var z := int(cell.y)
	var u := smoothstep(0.0, 1.0, cell.x - x)
	var v := smoothstep(0.0, 1.0, cell.y - z)
	var north := lerpf(HEIGHTS[z][x], HEIGHTS[z][x+1], u)
	var south := lerpf(HEIGHTS[z+1][x], HEIGHTS[z+1][x+1], u)
	var apron := Vector2(maxf(absf(p.x)-13.0,0.0), maxf(absf(p.y)-11.0,0.0)).length()
	return lerpf(north, south, v) * smoothstep(0.0, 8.0, apron)

static func route_distance(p: Vector2) -> float:
	var nearest := INF
	for route in ROUTES.values() + Lanes.ROUTES.values():
		for i in range(route.size() - 1):
			var a: Vector2 = route[i]
			var d: Vector2 = route[i+1] - a
			var t := clampf((p-a).dot(d) / d.length_squared(), 0, 1)
			nearest = minf(nearest, p.distance_to(a + d*t))
	return nearest

static func inward_normal(index: int) -> Vector2:
	var d: Vector2 = BOUNDARY[(index+1) % BOUNDARY.size()] - BOUNDARY[index]
	return Vector2(-d.y, d.x).normalized()

static func contains(p: Vector2, margin := 0.0) -> bool:
	for i in range(BOUNDARY.size()):
		if (p - BOUNDARY[i]).dot(inward_normal(i)) < margin: return false
	return true

static func bounded_center(center: Vector3, extents: Vector3) -> Vector3:
	var p := Vector2(center.x, center.z).clamp(Vector2(-42,-42), Vector2(42,42))
	# Convex half-planes inset by the entire rotated panel footprint.
	for pass_index in range(4):
		for i in range(BOUNDARY.size()):
			var n := inward_normal(i)
			var margin := absf(n.x)*extents.x + absf(n.y)*extents.z + 0.12
			p += n * maxf(0.0, margin - (p-BOUNDARY[i]).dot(n))
	var floor_y := height_at(p)
	for x in [-extents.x, 0.0, extents.x]:
		for z in [-extents.z, 0.0, extents.z]:
			floor_y = maxf(floor_y, height_at(p + Vector2(x,z)))
	return Vector3(p.x, clampf(center.y, floor_y + extents.y + 0.08, 12.0 - extents.y), p.y)

func _ready() -> void:
	build_ground()
	build_boundary()

func build_ground() -> void:
	var side := int(HALF_GROUND * 2 / GRID_STEP) + 1
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var colors := PackedColorArray()
	var uv := PackedVector2Array()
	var indices := PackedInt32Array()
	for z in range(side):
		for x in range(side):
			var p := Vector2(x * GRID_STEP - HALF_GROUND, z * GRID_STEP - HALF_GROUND)
			vertices.append(Vector3(p.x, height_at(p), p.y))
			var dx := height_at(p+Vector2(0.1,0)) - height_at(p-Vector2(0.1,0))
			var dz := height_at(p+Vector2(0,0.1)) - height_at(p-Vector2(0,0.1))
			normals.append(Vector3(-dx, 0.2, -dz).normalized())
			# Interpolate distance, not a clipped coverage mask, for clean path edges.
			colors.append(Color(minf(route_distance(p)/8.0,1.0),0,0))
			uv.append(p)
	for z in range(side-1):
		for x in range(side-1):
			var a := z*side+x
			indices.append_array(PackedInt32Array([a,a+1,a+side+1,a,a+side+1,a+side]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_TEX_UV] = uv
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://scripts/village_ground.gdshader")
	mat.set_shader_parameter("path_half_width", PATH_HALF_WIDTH)
	mat.set_shader_parameter("cobble_diff",preload("res://art/village/textures/cobblestone_floor_08_diff_1k.jpg"))
	mat.set_shader_parameter("cobble_normal",preload("res://art/village/textures/cobblestone_floor_08_nor_gl_1k.jpg"))
	mat.set_shader_parameter("cobble_rough",preload("res://art/village/textures/cobblestone_floor_08_rough_1k.jpg"))
	mesh.surface_set_material(0, mat)
	var ground := MeshInstance3D.new()
	ground.name = "Ground"
	ground.mesh = mesh
	add_child(ground)
	# Render and physics use the same triangles: no separate flat proxy floor.
	ground.create_trimesh_collision()

func quad(s: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, normal: Vector3) -> void:
	var points := [a,b,c,a,c,d]
	if (b-a).cross(c-a).dot(normal) > 0: points = [a,c,b,a,d,c]
	for point in points:
		s.set_normal(normal)
		s.set_uv(Vector2(point.x if absf(normal.z)>absf(normal.x) else point.z,point.y))
		s.add_vertex(point)

func build_boundary() -> void:
	var face := SurfaceTool.new()
	face.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rock := ShaderMaterial.new()
	rock.shader = preload("res://scripts/village_surface.gdshader")
	rock.set_shader_parameter("base_color",Color("94917c"))
	rock.set_shader_parameter("surface_kind",2)
	rock.set_shader_parameter("surface_roughness",0.95)
	face.set_material(rock)
	var top := SurfaceTool.new()
	top.begin(Mesh.PRIMITIVE_TRIANGLES)
	var turf := StandardMaterial3D.new()
	turf.albedo_color = Color("6f8746")
	turf.roughness = 1.0
	top.set_material(turf)
	for i in range(BOUNDARY.size()):
		var start: Vector2 = BOUNDARY[i]
		var end: Vector2 = BOUNDARY[(i+1) % BOUNDARY.size()]
		var n := inward_normal(i)
		var pieces := ceili(start.distance_to(end) / 2.0)
		for j in range(pieces):
			var a := start.lerp(end, float(j)/pieces)
			var b := start.lerp(end, float(j+1)/pieces)
			var ha := lerpf(CRESTS[i], CRESTS[(i+1)%CRESTS.size()], float(j)/pieces)
			var hb := lerpf(CRESTS[i], CRESTS[(i+1)%CRESTS.size()], float(j+1)/pieces)
			var foot_a := Vector3(a.x,height_at(a)-0.3,a.y)
			var foot_b := Vector3(b.x,height_at(b)-0.3,b.y)
			var rim_a := foot_a + Vector3.UP*(ha+0.3)
			var rim_b := foot_b + Vector3.UP*(hb+0.3)
			quad(face,foot_a,foot_b,rim_b,rim_a,Vector3(n.x,0,n.y))
			# Radial outer shoulder shares endpoints across corners: no bank cracks.
			var outer_a := Vector3(a.x*1.10,rim_a.y+0.4,a.y*1.10)
			var outer_b := Vector3(b.x*1.10,rim_b.y+0.4,b.y*1.10)
			quad(top,rim_a,rim_b,outer_b,outer_a,Vector3.UP)
			quad(face,outer_a,outer_b,Vector3(outer_b.x,height_at(b*1.10),outer_b.z),Vector3(outer_a.x,height_at(a*1.10),outer_a.z),Vector3(-n.x,0,-n.y))
	var bank := MeshInstance3D.new()
	bank.name = "BoundaryBank"
	bank.mesh = top.commit(face.commit())
	add_child(bank)
	bank.create_trimesh_collision()
