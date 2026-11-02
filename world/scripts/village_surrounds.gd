## Decorative foothills joined to the ground edge: no physics or destinations.
extends Node3D

const Landscape = preload("res://scripts/village_landscape.gd")
const FIR = preload("res://art/village/distant_fir.glb")
# Coarse outer rings meet every 0.5m ground-edge vertex through a stitched strip.
# This keeps the seam exact without carrying the dense walking grid into the hills.
const SUBDIVISIONS := 24
const EDGE_STEPS := 8
const CORNERS := [Vector2(-48,-48), Vector2(48,-48), Vector2(48,48), Vector2(-48,48)]
const RADII := [0.0, 4.0, 10.0, 18.0, 30.0, 48.0, 72.0, 105.0]
const HILLS := [Vector4(-65,-23,18,22), Vector4(66,18,13,25), Vector4(-3,-66,16,30), Vector4(8,69,12,25)]

func point(sample: float, distance: float) -> Vector3:
	var segment := fposmod(sample / SUBDIVISIONS, float(CORNERS.size()))
	var i := int(segment)
	var j := (i + 1) % CORNERS.size()
	var b: Vector2 = CORNERS[i].lerp(CORNERS[j], segment-i)
	var p := b + b.normalized() * distance
	var edge := Landscape.height_at(b)
	var height := 2.0
	for hill in HILLS:
		height += hill.z * exp(-p.distance_squared_to(Vector2(hill.x,hill.y)) / (hill.w*hill.w))
	height += sin(p.x*.12)*cos(p.y*.09)*1.2
	height = lerpf(edge, height, smoothstep(0,24,distance))
	height = lerpf(height, -5, smoothstep(72,105,distance))
	return Vector3(p.x,height,p.y)

func _ready() -> void:
	var count := CORNERS.size() * SUBDIVISIONS
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var indices := PackedInt32Array()
	var fine_count := count * EDGE_STEPS
	for s in range(fine_count):
		var p := point(float(s)/EDGE_STEPS,0)
		vertices.append(p)
		var xz := Vector2(p.x,p.z)
		var dx := Landscape.height_at(xz+Vector2(.1,0))-Landscape.height_at(xz-Vector2(.1,0))
		var dz := Landscape.height_at(xz+Vector2(0,.1))-Landscape.height_at(xz-Vector2(0,.1))
		normals.append(Vector3(-dx,.2,-dz).normalized())
	for distance in RADII.slice(1):
		for s in range(count):
			vertices.append(point(s,distance))
			var tangent := point(s+.05,distance)-point(s-.05,distance)
			var radial := point(s,distance+.05)-point(s,distance-.05)
			normals.append(tangent.cross(radial).normalized())
	for s in range(count):
		var outer := fine_count+s
		for step in range(EDGE_STEPS):
			var inner := s*EDGE_STEPS+step
			indices.append_array(PackedInt32Array([inner,outer,(inner+1)%fine_count]))
		indices.append_array(PackedInt32Array([((s+1)*EDGE_STEPS)%fine_count,outer,fine_count+(s+1)%count]))
	for r in range(RADII.size()-2):
		for s in range(count):
			var a := fine_count+r*count+s
			var b := fine_count+r*count+(s+1)%count
			indices.append_array(PackedInt32Array([a,a+count,b+count,a,b+count,b]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	var terrain := MeshInstance3D.new()
	terrain.name = "Foothills"
	terrain.mesh = ArrayMesh.new()
	terrain.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	var material := ShaderMaterial.new()
	material.shader = preload("res://scripts/village_foothills.gdshader")
	terrain.material_override = material
	terrain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(terrain)
	# One instanced mesh, three small opaque surfaces. Distant trees cast no
	# shadows into the playable area and require no per-frame script processing.
	var source := FIR.instantiate()
	var trees := MultiMeshInstance3D.new()
	trees.name = "Firs"
	trees.multimesh = MultiMesh.new()
	trees.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	trees.multimesh.mesh = source.find_children("*","MeshInstance3D")[0].mesh
	var placements: Array[Transform3D] = []
	var rng := RandomNumberGenerator.new()
	rng.seed = 2208
	for r in range(1,6):
		for s in range(count):
			if rng.randf() > .24: continue
			var p := point(s,RADII[r])
			# Keep the two distant track glimpses intermittently visible.
			if p.z < -51 and absf(p.x-(10+10*sin((p.z+50)*.06))) < 3: continue
			if p.z > 51 and absf(p.x-(-15+8*sin((p.z-50)*.07))) < 3: continue
			var scale := rng.randf_range(.65,1.25)
			placements.append(Transform3D(Basis(Vector3.UP,rng.randf()*TAU).scaled(Vector3(scale,scale*rng.randf_range(.9,1.2),scale)),p-Vector3(0,.12,0)))
	trees.multimesh.instance_count = placements.size()
	for i in range(placements.size()): trees.multimesh.set_instance_transform(i,placements[i])
	trees.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(trees)
	source.free()
