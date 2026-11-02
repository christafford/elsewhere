## Matched named-host rendering samples; not a sustained/target-device gate.
extends SceneTree
func _initialize():call_deferred("run")
func run():
	if DisplayServer.get_name()=="headless":
		push_error("Animal render cost requires an actual renderer")
		quit(1);return
	var disabled:bool="--no-animals" in OS.get_cmdline_user_args()
	var label:="disabled" if disabled else "enabled"
	var output:="res://../.tools/p22-t14"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	var scene=load("res://scenes/main.tscn").instantiate();root.add_child(scene)
	var herd=scene.get_node("Animals")
	if not disabled:
		var deadline:=Time.get_ticks_msec()+45000
		while not herd.initialized and Time.get_ticks_msec()<deadline:await physics_frame
		if not herd.initialized:
			push_error("Animal render sample initialization timed out")
			await scene.desktop_runtime.shutdown()
			quit(1);return
	var camera:=Camera3D.new();scene.add_child(camera);camera.current=true
	var samples:=[]
	for view in [["square",Vector3(0,1.6,5),Vector3(-15,.5,4)],["meadow",Vector3(-10,2.8,26),Vector3(-20,1.6,30)],["east",Vector3(14,2,8),Vector3(25,1,14)]]:
		camera.position=view[1];camera.look_at(view[2])
		for frame in range(120):await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(output.path_join(label+"-"+view[0]+".png"))
		var times:Array[float]=[];var physics:Array[float]=[];var previous:=Time.get_ticks_usec()
		for frame in range(180):
			await process_frame
			var now:=Time.get_ticks_usec();times.append((now-previous)/1000.0);previous=now
			physics.append(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)*1000)
		times.sort();physics.sort()
		samples.append({"view":view[0],"median_ms":times[90],"p95_ms":times[171],"physics_median_ms":physics[90],"physics_p95_ms":physics[171],"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"primitives":Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)})
	var report:={"renderer":RenderingServer.get_video_adapter_name(),"mode":DisplayServer.get_name(),"viewport":root.size,"animals":0 if disabled else herd.animals.size(),"samples":samples}
	FileAccess.open(output.path_join("render-cost-"+label+".json"),FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
	print("ANIMAL_RENDER_COST ",JSON.stringify(report))
	await scene.desktop_runtime.shutdown()
	print("ANIMAL_RENDER_COST_OK failures=0")
	quit()
