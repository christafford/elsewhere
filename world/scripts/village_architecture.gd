## Fixed village models and usable ground floors; no desktop/runtime ownership.
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

# Original local front plane and entry center; rear depth grows by 65 percent.
const ENTRY_RUN := 3.0
const ROOMS := {"Lodge": Vector3(5,3.75,0), "Guildhall": Vector3(3.9,3.25,0), "Workshop": Vector3(4,3.25,-1.8)}

func _ready() -> void:
	for label in SITES:
		var site: Dictionary = SITES[label]
		var floor_y := Landscape.height_at(site.xz)
		for x in [-site.half.x,0.0,site.half.x]:
			for z in [-site.half.y,0.0,site.half.y]:
				floor_y = maxf(floor_y,Landscape.height_at(site.xz+Vector2(x,z)))
		if ROOMS.has(label):
			var room: Vector3 = ROOMS[label]
			var rotation := Basis(Vector3.UP,site.yaw)
			# Sample the actual rotated/extended footprint, including its interior.
			for x in range(-ceili(room.x),ceili(room.x)+1):
				for z in range(-ceili(room.y*1.65),ceili(room.y)+1):
					var local := Vector3(clampf(x,-room.x,room.x),0,clampf(z,-room.y*1.65,room.y))
					var offset := rotation * local
					floor_y = maxf(floor_y,Landscape.height_at(site.xz+Vector2(offset.x,offset.z)))
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
			entrance_ramp(model,ROOMS[label].y,ROOMS[label].z)
			var interior := Node3D.new()
			interior.name = "Interior"
			model.add_child(interior)
			var workspace := Node3D.new()
			workspace.name = "Workspace"
			workspace.set_script(preload("res://scripts/pavilion_workspace.gd"))
			workspace.position.z = -1.0
			interior.add_child(workspace)
			if label == "Workshop": workspace.get_node("EastStool").position.x = 1.0
			var lamp := OmniLight3D.new()
			lamp.name = "PendantLight"
			lamp.position = Vector3(0,2.5,-1.65)
			lamp.light_color = Color("ffe2ad")
			lamp.light_energy = 1.6
			lamp.omni_range = 8.0
			lamp.shadow_enabled = true
			interior.add_child(lamp)


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

func entrance_ramp(model: Node3D, front: float, door_x: float) -> void:
	var foot := model.to_global(Vector3(door_x,0,front+ENTRY_RUN))
	var bottom := Landscape.height_at(Vector2(foot.x,foot.z))-model.position.y-.015
	var ramp := SurfaceTool.new()
	ramp.begin(Mesh.PRIMITIVE_TRIANGLES)
	ramp.set_material(stone_finish())
	var a := Vector3(door_x-1.2,bottom,front+ENTRY_RUN)
	var b := Vector3(door_x+1.2,bottom,front+ENTRY_RUN)
	var c := Vector3(door_x+1.2,0,front+.6)
	var d := Vector3(door_x-1.2,0,front+.6)
	var e := Vector3(door_x+1.2,0,front-.2)
	var f := Vector3(door_x-1.2,0,front-.2)
	# Reach a level landing before the floor edge so the capsule clears its lip.
	# Visible top and skirts are the collision; no controller special case.
	for p in [a,d,c,a,c,b, d,f,e,d,e,c, a,a-Vector3.UP*.3,d-Vector3.UP*2,a,d-Vector3.UP*2,d, b,c,c-Vector3.UP*2,b,c-Vector3.UP*2,b-Vector3.UP*.3, d,d-Vector3.UP*2,f-Vector3.UP*2,d,f-Vector3.UP*2,f, c,e,e-Vector3.UP*2,c,e-Vector3.UP*2,c-Vector3.UP*2]:
		ramp.set_uv(Vector2(p.x,p.z))
		ramp.add_vertex(p)
	ramp.generate_normals()
	var mesh := MeshInstance3D.new()
	mesh.name = "EntranceRamp"
	mesh.mesh = ramp.commit()
	model.add_child(mesh)
	add_collision(mesh)

# Match access surfaces to the carved stone; geometry/collision stay unchanged.
func stone_finish() -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = Materials.SURFACE
	mat.set_shader_parameter("base_color",Materials.COLORS["cut_stone"])
	mat.set_shader_parameter("surface_kind",8)
	mat.set_shader_parameter("surface_roughness",0.95)
	return mat
