## P22-T13: containment, exact terrain seam and actual open-perimeter captures.
extends "res://tests/village_landscape.gd"

const Surrounds = preload("res://scripts/village_surrounds.gd")
const Upstairs = preload("res://scripts/village_upstairs.gd")

func run() -> void:
	output_dir = ProjectSettings.globalize_path("res://../.tools/p22-t13/boundary").simplify_path()
	DirAccess.make_dir_recursive_absolute(output_dir)
	study = load(ProjectSettings.get_setting("application/run/main_scene")).instantiate()
	root.add_child(study)
	current_scene = study
	terminal = study.terminal_screen
	app = study.application_mode
	objects = study.application_objects
	walker = study.get_node("Player")
	var graphical := DisplayServer.get_name() != "headless"
	if graphical: root.grab_focus()
	await frames(20)
	var landscape: Node3D = study.get_node("Landscape")
	check(not landscape.has_node("BoundaryBank"),"Visible enclosing bank remains")
	var boundary: Node3D = landscape.get_node("TravelBoundary")
	check(boundary.find_children("*","GeometryInstance3D",true,false).is_empty(),"Travel boundary renders geometry")
	check(boundary.get_child_count()==10,"Travel boundary lost a section")
	var surrounds: Node3D = study.get_node("MountainBackdrop/Surrounds")
	var mesh: ArrayMesh = surrounds.get_node("Foothills").mesh
	var vertices: PackedVector3Array = mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	var seam_count := Surrounds.CORNERS.size()*Surrounds.SUBDIVISIONS*Surrounds.EDGE_STEPS
	for i in range(seam_count):
		var p := vertices[i]
		check(is_equal_approx(maxf(absf(p.x),absf(p.z)),Landscape.HALF_GROUND),"Foothills leave a ground-edge gap")
		check(absf(p.x/Landscape.GRID_STEP-roundf(p.x/Landscape.GRID_STEP))<.001 and absf(p.z/Landscape.GRID_STEP-roundf(p.z/Landscape.GRID_STEP))<.001,"Seam misses ground grid")
		check(absf(p.y-Landscape.height_at(Vector2(p.x,p.z)))<.0001,"Foothills seam height mismatch")
		check(p.distance_to(vertices[(i+1)%seam_count])<.51,"Seam skips a ground edge")
	check(mesh.get_faces().size()/3<5000,"Foothill geometry budget exceeded")
	var faces := mesh.get_faces()
	for i in range(0,faces.size(),3):
		check((faces[i+2]-faces[i]).cross(faces[i+1]-faces[i]).y>0,"Foothill triangle faces down or degenerates")
	# Exercise all polygon corners with ordinary diagonal movement and jumping.
	# Section midpoints are independently covered by outdoor_startup.gd.
	for i in range(Landscape.BOUNDARY.size()):
		var corner: Vector2 = Landscape.BOUNDARY[i]
		var bisector := (Landscape.inward_normal(i)+Landscape.inward_normal((i+9)%10)).normalized()
		await place_at(corner+bisector*1.5)
		walker.rotation.y = atan2(bisector.x,bisector.y)+PI/4
		await mouse(Vector2(640,400),true,false,MOUSE_BUTTON_RIGHT)
		await key(KEY_W,true)
		await key(KEY_D,true)
		await tap(KEY_SPACE)
		await frames(80)
		await key(KEY_W,false)
		await key(KEY_D,false)
		await mouse(Vector2(640,400),false,false,MOUSE_BUTTON_RIGHT)
		var p := Vector2(walker.position.x,walker.position.z)
		check(Landscape.contains(p,.19) and p.distance_to(corner)<.65 and walker.is_on_floor(),"Corner containment/reach failed: "+str(i))
		# The full rotated panel footprint stays within both incident edges.
		var extents := Vector3(.9,.6,.7)
		var bounded: Vector3 = study.bounded_center(Vector3(corner.x-bisector.x*4,2,corner.y-bisector.y*4),extents)
		for x in [-extents.x,extents.x]:
			for z in [-extents.z,extents.z]:
				check(Landscape.contains(Vector2(bounded.x+x,bounded.z+z),.1),"Panel footprint escapes corner")
	await tap(KEY_HOME)
	await frames(15)
	check(walker.is_on_floor() and walker.position.distance_to(Vector3(0,0,5))<.03,"Home from boundary failed")
	# Use a real existing movable stool and its production collision/mass/CCD.
	var stool: RigidBody3D = study.get_node("Architecture/Pavilion/Workspace/WestStool")
	var original := stool.global_transform
	for i in range(10):
		var midpoint: Vector2 = (Landscape.BOUNDARY[i]+Landscape.BOUNDARY[(i+1)%10])*.5
		var inward := Landscape.inward_normal(i)
		var start := midpoint+inward*1.2
		stool.freeze = true
		stool.global_transform = Transform3D(Basis.IDENTITY,Vector3(start.x,Landscape.height_at(start)+.1,start.y))
		stool.linear_velocity = Vector3.ZERO
		await frames(2)
		stool.freeze = false
		stool.sleeping = false
		for frame in range(70):
			stool.apply_central_force(Vector3(-inward.x,0,-inward.y)*stool.mass*15)
			await physics_frame
		var p := Vector2(stool.global_position.x,stool.global_position.z)
		var clearance := (p-midpoint).dot(inward)
		check(Landscape.contains(p,.15) and clearance<.65,"Movable stool escapes or cannot reach boundary: "+str(i))
		check(stool.global_position.y>Landscape.height_at(p)-.1,"Stool falls through boundary ground")
	stool.freeze = true
	stool.global_transform = original
	stool.linear_velocity = Vector3.ZERO
	await frames(2)
	stool.freeze = false
	if graphical:
		for i in range(10):
			var midpoint: Vector2 = (Landscape.BOUNDARY[i]+Landscape.BOUNDARY[(i+1)%10])*.5
			var inward := Landscape.inward_normal(i)
			await place_at(midpoint+inward*1.2)
			walker.camera.look_at(Vector3(midpoint.x-inward.x*35,Landscape.height_at(midpoint)+3,midpoint.y-inward.y*35))
			await capture("perimeter-%02d.png" % i)
		for spec in Upstairs.definitions():
			if spec.id not in ["LanternInn","Library","MeadowInn"]: continue
			var building: Node3D = study.get_node(spec.path)
			walker.position = building.to_global(Vector3(.9,Upstairs.FLOOR+.04,-1))
			await frames(15)
			check(walker.is_on_floor(),"Upstairs capture lacks support: "+spec.id)
			walker.camera.look_at(building.to_global(Vector3(-1,4.5,spec.depth/2+30)))
			await capture(spec.id.to_lower()+"-room.png")
			# Windows are decorative. Inspect the terrain from this floor's height
			# outside the shell; this diagnostic camera is not accessible gameplay.
			walker.set_physics_process(false)
			var outward := Vector3(building.global_position.x,0,building.global_position.z).normalized()
			walker.global_position = building.global_position+outward*8+Vector3.UP*Upstairs.FLOOR
			walker.camera.look_at(walker.camera.global_position+outward*45)
			await capture(spec.id.to_lower()+"-elevated-exterior.png")
			walker.set_physics_process(true)
	print("BOUNDARY_GEOMETRY seam_vertices=",seam_count," foothill_triangles=",mesh.get_faces().size()/3)
	await study.desktop_runtime.shutdown()
	print("VILLAGE_BOUNDARY_OK mode=",DisplayServer.get_name()," corners=10 stools=10 failures=",failures)
	quit(1 if failures else 0)
