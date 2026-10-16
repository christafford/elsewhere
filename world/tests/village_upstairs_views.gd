## Final geometry/render inspection only; walking/live apps use village_upstairs.gd.
extends "res://tests/village_interiors.gd"
const Upstairs = preload("res://scripts/village_upstairs.gd")

func run() -> void:
	output_dir = ProjectSettings.globalize_path("res://../.tools/p22-t12/views").simplify_path()
	DirAccess.make_dir_recursive_absolute(output_dir)
	study = load("res://scenes/main.tscn").instantiate()
	root.add_child(study)
	current_scene = study
	terminal = study.terminal_screen
	app = study.application_mode
	objects = study.application_objects
	walker = study.get_node("Player")
	var graphical := DisplayServer.get_name()!="headless"
	if graphical: root.grab_focus()
	await frames(20)
	for spec in Upstairs.definitions():
		var building: Node3D = study.get_node(spec.path)
		if spec.id=="LanternInn":
			var tree: Node3D = study.get_node("Garden/CourtyardTree6")
			check(Landscape.contains(Vector2(tree.position.x,tree.position.z),.5),"Moved tree trunk leaves playable site")
			check(Landscape.route_distance(Vector2(tree.position.x,tree.position.z))>1.0,"Moved tree trunk obstructs a lane")
			for mesh in tree.find_children("*","MeshInstance3D",true,false):
				var bounds: AABB = mesh.get_aabb()
				for corner in range(8):
					var p := building.to_local(mesh.to_global(bounds.get_endpoint(corner)))
					check(p.x>spec.width/2+.15,"Tree canopy enters occupied upper room")
		# The final exterior-only flue trim must leave enclosed upper rooms and
		# continuous roofs. Scan a grid above all furniture/guards below the roof.
		var samples := 0
		for x in range(-int(spec.width/2)+1,int(spec.width/2)):
			for z in range(-int(spec.depth/2*spec.rear_scale)+1,int(spec.depth/2)):
				var p := building.to_global(Vector3(x,Upstairs.FLOOR+2.15,z))
				var hit := root.world_3d.direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(p,p+Vector3.UP*12,1))
				check(not hit.is_empty(),"Missing upper roof/ceiling: "+spec.id+str(Vector2(x,z)))
				samples += 1
		var points := Upstairs.stair_points(spec)
		var views := [
			["downstairs",Vector3(0,0,.8),Vector3(spec.width/2-1,2,0)],
			["stairs",points[0]+Vector3(0,0,.28),points[1]+Vector3.UP],
			["landing",points[1]+Vector3(0,0,-.45),points[0]+Vector3.UP],
			["upstairs",Vector3(0,Upstairs.FLOOR,.65),Vector3(-1.5,4.7,-spec.depth/2*spec.rear_scale+.7)],
			["worktable",Vector3(0,Upstairs.FLOOR,.65),Vector3(-2,Upstairs.FLOOR+1.48,-.9)],
			["ceiling",Vector3(0,Upstairs.FLOOR,1.0),Vector3(-2.5,6.9,-1.2)],
			["front-room",Vector3(.9,Upstairs.FLOOR,-1.0),Vector3(-1,4.4,spec.depth/2-.3)]
		]
		if graphical:
			for view in views:
				walker.release_pointer()
				walker.position = building.to_global(view[1]+Vector3.UP*.04)
				await frames(15)
				check(walker.is_on_floor(),"Viewpoint lacks floor support: "+spec.id+view[0])
				face(building.to_global(view[2]))
				await capture(spec.id.to_lower()+"-"+view[0]+".png")
		print("UPSTAIRS_ROOF_GRID building=",spec.id," samples=",samples)
	await study.desktop_runtime.shutdown()
	print("VILLAGE_UPSTAIRS_VIEWS_OK mode=",DisplayServer.get_name()," failures=",failures)
	quit(1 if failures else 0)
