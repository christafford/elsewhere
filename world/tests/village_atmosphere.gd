## Matched eye-level views and bounded rendering-cost comparison for P22-T08.
extends "res://tests/village_landscape.gd"

const VIEWS := [
	["arrival", Vector2(0,5), Vector3(-4,4,-18)],
	["north-outlook", Vector2(5,-33), Vector3(8,12,-90)],
	["east-outlook", Vector2(31,13), Vector3(80,13,18)],
	["south-outlook", Vector2(-8,34), Vector3(-7,12,83)],
	["west-outlook", Vector2(-30,-15), Vector3(-80,15,-24)],
	["south-return", Vector2(-6,28), Vector3(-3,5,-15)],
	["pavilion-edge", Vector2(-11,24), Vector3(-27,10,66)],
]

func run() -> void:
	var baseline := "--baseline" in OS.get_cmdline_user_args()
	var label := "baseline" if baseline else "final"
	output_dir = ProjectSettings.globalize_path("res://../.tools/p22-t08/"+label).simplify_path()
	DirAccess.make_dir_recursive_absolute(output_dir)
	study = load(ProjectSettings.get_setting("application/run/main_scene")).instantiate()
	root.add_child(study)
	current_scene = study
	terminal = study.terminal_screen
	app = study.application_mode
	objects = study.application_objects
	walker = study.get_node("Player")
	await frames(20)
	check(terminal.session != null and terminal.session.is_running() and objects.bindings.is_empty(),"Atmosphere changed empty desktop startup")
	if not baseline:
		var surrounds: Node3D = study.get_node("MountainBackdrop/Surrounds")
		check(surrounds.find_children("*","CollisionObject3D",true,false).is_empty(),"Decorative surroundings add collision")
		check(surrounds.get_node("Firs").multimesh.instance_count <= 160,"Distant tree budget exceeded")
		check(surrounds.get_node("Foothills").mesh.get_faces().size()/3 < 5000,"Foothill geometry budget exceeded")
		var firs: MultiMesh = surrounds.get_node("Firs").multimesh
		check(firs.instance_count > 0,"Distant grove is empty")
		# Dummy headless rendering does not retain MultiMesh transform readback.
		# Verify every actual rendered instance on the graphical path.
		if DisplayServer.get_name() != "headless":
			for i in range(firs.instance_count):
				var p := firs.get_instance_transform(i).origin
				check(not Landscape.contains(Vector2(p.x,p.z)),"Distant tree entered playable area")
		print("ATMOSPHERE_GEOMETRY firs=",firs.instance_count," tree_triangles=",firs.mesh.get_faces().size()/3," foothill_triangles=",surrounds.get_node("Foothills").mesh.get_faces().size()/3)
	if DisplayServer.get_name() != "headless":
		root.grab_focus()
		var report: Array = []
		for view in VIEWS:
			await place_at(view[1])
			walker.camera.look_at(view[2])
			await capture(view[0]+".png")
			var times: Array[float] = []
			var previous := Time.get_ticks_usec()
			for sample in range(120):
				await process_frame
				var now := Time.get_ticks_usec()
				times.append((now-previous)/1000.0)
				previous = now
			times.sort()
			var result := {"view":view[0],"median_ms":times[60],"p95_ms":times[114],"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"primitives":Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)}
			report.append(result)
			print("ATMOSPHERE_SAMPLE ",JSON.stringify(result))
		FileAccess.open(output_dir.path_join("render-cost.json"),FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
	await study.desktop_runtime.shutdown()
	print("VILLAGE_ATMOSPHERE_OK mode=",DisplayServer.get_name()," baseline=",baseline," failures=",failures)
	quit(1 if failures else 0)
