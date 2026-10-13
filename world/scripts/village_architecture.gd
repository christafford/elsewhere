## P22-T04: fixed exterior model placement; no desktop/runtime ownership.
extends Node3D

const Landscape = preload("res://scripts/village_landscape.gd")
const Materials = preload("res://scripts/village_materials.gd")
const SITES := {
	"Lodge": {"model": "alpine_lodge", "xz": Vector2(-12,-16), "yaw": 0.0, "half": Vector2(5,3.75)},
	"Guildhall": {"model": "guildhall", "xz": Vector2(9.5,-17), "yaw": 0.0, "half": Vector2(3.9,3.25)},
	"Workshop": {"model": "stone_workshop", "xz": Vector2(18,-9), "yaw": -PI/2, "half": Vector2(3.25,5.7)},
	"Fountain": {"model": "square_fountain", "xz": Vector2(-5,-4), "yaw": 0.0, "half": Vector2(3.15,3.15)},
	"Pavilion": {"model": "work_pavilion", "xz": Vector2(-18,18), "yaw": 0.0, "half": Vector2(4.5,3.5)},
}

func _ready() -> void:
	for label in SITES:
		var site: Dictionary = SITES[label]
		var floor_y := Landscape.height_at(site.xz)
		for x in [-site.half.x,0.0,site.half.x]:
			for z in [-site.half.y,0.0,site.half.y]:
				floor_y = maxf(floor_y,Landscape.height_at(site.xz+Vector2(x,z)))
		var model: Node3D = load("res://art/village/%s.glb" % site.model).instantiate()
		model.name = label
		add_child(model)
		model.position = Vector3(site.xz.x,floor_y+0.02,site.xz.y)
		model.rotation.y = site.yaw
		Materials.apply(model)
		add_collision(model)
		if label == "Pavilion":
			pavilion_access(model)
			var workspace := Node3D.new()
			workspace.name = "Workspace"
			workspace.set_script(preload("res://scripts/pavilion_workspace.gd"))
			model.add_child(workspace)
		elif label in ["Lodge","Guildhall","Workshop"]:
			entrance_steps(model,3.75 if label=="Lodge" else 3.25,-1.8 if label=="Workshop" else 0.0)


func add_collision(node: Node) -> void:
	if node is MeshInstance3D:
		node.create_trimesh_collision()
		for child in node.get_children():
			if child is StaticBody3D: child.add_to_group("village_architecture_collision")
	# Generated physics children are not meshes and need no further collision.
	for child in node.get_children(): add_collision(child)

func pavilion_access(model: Node3D) -> void:
	# A continuous north ramp provides ordinary walking access to the workspace.
	var mat := stone_finish()
	var skirt := MeshInstance3D.new()
	skirt.name = "Foundation"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(9,1.8,7)
	mesh.material = mat
	skirt.mesh = mesh
	model.add_child(skirt)
	skirt.position.y = -1.04
	add_collision(skirt)
	var bottom_z := -8.5
	var bottom_y := Landscape.height_at(Vector2(model.position.x,model.position.z+bottom_z))-model.position.y-0.01
	var ramp := SurfaceTool.new()
	ramp.begin(Mesh.PRIMITIVE_TRIANGLES)
	ramp.set_material(mat)
	var a := Vector3(-1.6,bottom_y,bottom_z)
	var b := Vector3(1.6,bottom_y,bottom_z)
	var c := Vector3(1.6,0,-3.45)
	var d := Vector3(-1.6,0,-3.45)
	# Clockwise top surface and closed sides, buried 20cm below the terrain.
	for p in [a,b,c,a,c,d, a,d,d-Vector3.UP*1.8,a,d-Vector3.UP*1.8,a-Vector3.UP*0.2, b,c-Vector3.UP*1.8,c,b,b-Vector3.UP*0.2,c-Vector3.UP*1.8]:
		ramp.set_uv(Vector2(p.x,p.z))
		ramp.add_vertex(p)
	ramp.generate_normals()
	var ramp_node := MeshInstance3D.new()
	ramp_node.name = "EntranceRamp"
	ramp_node.mesh = ramp.commit()
	model.add_child(ramp_node)
	add_collision(ramp_node)

func entrance_steps(model: Node3D, front: float, door_x: float) -> void:
	var foot := model.to_global(Vector3(door_x,0,front+2.3))
	var rise := model.position.y-Landscape.height_at(Vector2(foot.x,foot.z))
	var count := maxi(1,ceili(rise/0.16))
	var mat := stone_finish()
	for i in range(count):
		var step := MeshInstance3D.new()
		step.name = "EntranceStep%s" % i
		var mesh := BoxMesh.new()
		var top := -float(i)*rise/count
		mesh.size = Vector3(2.25,0.18+(count-i)*rise/count,0.32)
		mesh.material = mat
		step.mesh = mesh
		model.add_child(step)
		step.position = Vector3(door_x,top-mesh.size.y/2,front+0.45+i*0.3)
		add_collision(step)

# Match access surfaces to the carved stone; geometry/collision stay unchanged.
func stone_finish() -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = Materials.SURFACE
	mat.set_shader_parameter("base_color",Color("85877b"))
	mat.set_shader_parameter("surface_kind",8)
	mat.set_shader_parameter("surface_roughness",0.95)
	return mat
