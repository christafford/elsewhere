## P22-T11: location-owned buildings, trade artifacts and ordinary panel supports.
extends "res://scripts/village_architecture.gd"

static func definitions() -> Array:
	return JSON.parse_string(FileAccess.get_file_as_string("res://art/village/expansion.json"))

func _ready() -> void:
	for spec in definitions():
		var xz := Vector2(spec.xz[0],spec.xz[1])
		var yaw := deg_to_rad(float(spec.yaw))
		var rotation := Basis(Vector3.UP,yaw)
		var floor_y := Landscape.height_at(xz)
		for x in range(-ceili(spec.width/2),ceili(spec.width/2)+1):
			for z in range(-ceili(spec.depth/2),ceili(spec.depth/2)+1):
				var offset := rotation * Vector3(clampf(x,-spec.width/2,spec.width/2),0,clampf(z,-spec.depth/2,spec.depth/2))
				floor_y = maxf(floor_y,Landscape.height_at(xz+Vector2(offset.x,offset.z)))
		var model: Node3D = load("res://art/village/village_%s.glb" % spec.id.to_lower()).instantiate()
		model.name = spec.id
		add_child(model)
		model.position = Vector3(xz.x,floor_y+.02,xz.y)
		model.rotation.y = yaw
		Materials.apply(model)
		add_collision(model)
		entrance_ramp(model,spec.depth/2,0)
		var artifacts: Node3D = load("res://art/village/village_%s_artifacts.glb" % spec.id.to_lower()).instantiate()
		artifacts.name = "Artifacts"
		model.add_child(artifacts)
		Materials.apply(artifacts)
		add_collision(artifacts)
		worktable(model)
		var lamp := OmniLight3D.new()
		lamp.name = "InteriorLight"
		lamp.position = Vector3(0,2.5,-1)
		lamp.light_color = Color("ffe2ad")
		lamp.light_energy = 1.6
		lamp.omni_range = 6.0
		lamp.shadow_enabled = true
		model.add_child(lamp)
		for line in [[spec.name,3.77,64],[spec.subtitle,3.47,32]]:
			var sign := Label3D.new()
			sign.name = "Sign" if line[2]==64 else "Trade"
			sign.text = line[0]
			sign.font_size = line[2]
			sign.pixel_size = .0035
			sign.modulate = Color("f6e1b1")
			sign.outline_size = 2
			sign.no_depth_test = false
			var sign_offset := 1.46 if spec.kind in ["inn","meadow"] else .37
			sign.position = Vector3(0,line[1],spec.depth/2+sign_offset)
			model.add_child(sign)

func worktable(model: Node3D) -> void:
	# One retained trestle table per destination; props and central aisle stay clear.
	var body := StaticBody3D.new()
	body.name = "Worktable"
	model.add_child(body)
	body.position = Vector3(-2,0,-.9)
	body.add_to_group("village_workspace_collision")
	var mesh: Node3D = preload("res://art/village/pavilion_worktable.glb").instantiate()
	body.add_child(mesh)
	Materials.apply(mesh)
	for part in [[Vector3(2.52,.12,1.04),Vector3(0,.9,0)],
		[Vector3(1.8,.03,.62),Vector3(0,.965,.02)],
		[Vector3(.22,.85,.95),Vector3(-.9,.425,0)],
		[Vector3(.22,.85,.95),Vector3(.9,.425,0)]]:
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = part[0]
		collision.shape = shape
		collision.position = part[1]
		body.add_child(collision)
	var anchor := Marker3D.new()
	anchor.name = "WorkAnchor"
	anchor.position = Vector3(0,.98,.02)
	body.add_child(anchor)
