## Decorative foothills outside the established bank: no physics or destinations.
extends Node3D

const Landscape = preload("res://scripts/village_landscape.gd")
const FIR = preload("res://art/village/distant_fir.glb")
const SUBDIVISIONS := 12
const RADII := [0.0, 4.0, 10.0, 18.0, 30.0, 48.0, 72.0, 105.0]
const HILLS := [Vector4(-65,-23,18,22), Vector4(66,18,13,25), Vector4(-3,-66,16,30), Vector4(8,69,12,25)]

func point(sample: float, distance: float) -> Vector3:
	var segment := fposmod(sample / SUBDIVISIONS, float(Landscape.BOUNDARY.size()))
	var i := int(segment)
	var j := (i + 1) % Landscape.BOUNDARY.size()
	var b: Vector2 = Landscape.BOUNDARY[i].lerp(Landscape.BOUNDARY[j], segment-i)
	var p := b * 1.10 + b.normalized() * distance
	var edge := Landscape.height_at(b) + lerpf(Landscape.CRESTS[i], Landscape.CRESTS[j], segment-i) + .38
	var height := 2.0
	for hill in HILLS:
		height += hill.z * exp(-p.distance_squared_to(Vector2(hill.x,hill.y)) / (hill.w*hill.w))
	height += sin(p.x*.12)*cos(p.y*.09)*1.2
	height = lerpf(edge, height, smoothstep(0,18,distance))
	height = lerpf(height, -5, smoothstep(72,105,distance))
	return Vector3(p.x,height,p.y)

func _ready() -> void:
	var count := Landscape.BOUNDARY.size() * SUBDIVISIONS
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var indices := PackedInt32Array()
	for distance in RADII:
		for s in range(count):
			vertices.append(point(s,distance))
			var tangent := point(s+.05,distance)-point(s-.05,distance)
			var radial := point(s,distance+.05)-point(s,maxf(0,distance-.05))
			normals.append(tangent.cross(radial).normalized())
	for r in range(RADII.size()-1):
		for s in range(count):
			var a := r*count+s
			var b := r*count+(s+1)%count
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
