## Forward+ feature/render samples. Stills and short samples are not human acceptance.
extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Rendering upgrade acceptance needs an actual GPU")
		quit(1)
		return
	check(RenderingServer.get_current_rendering_method() == "forward_plus", "Default renderer is not Forward+")
	var scene: Node3D = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	var env: Environment = scene.get_node("WorldEnvironment").environment
	var sun: DirectionalLight3D = scene.get_node("Sun")
	check(env.ssao_enabled and sun.shadow_contact_shadows_allow, "Forward+ contact/ambient occlusion is disabled")
	check(ProjectSettings.get_setting("rendering/lights_and_shadows/contact_shadow/enabled") and ProjectSettings.get_setting("rendering/lights_and_shadows/multi_bounce_occlusion/enabled"), "4.8 lighting settings missing")
	var baseline := "--features-off" in OS.get_cmdline_user_args()
	if baseline:
		env.ssao_enabled = false
		sun.shadow_contact_shadows_allow = false
	var output := ProjectSettings.globalize_path("res://../.tools/godot48-render/" + ("baseline" if baseline else "final"))
	DirAccess.make_dir_recursive_absolute(output)
	var textures := []
	for family in ["grey_plaster", "rough_wood", "cobblestone_floor_08"]:
		for channel in ["diff", "nor_gl", "rough"]:
			var path := "res://art/village/textures/%s_%s_1k.jpg" % [family, channel]
			var texture = load(path)
			check(texture is StreamedTexture2D, "World texture does not stream: " + path)
			textures.append(texture)
	var camera := Camera3D.new()
	scene.add_child(camera)
	camera.current = true
	var samples := []
	for view in [["arrival", Vector3(0,1.65,5), Vector3(0,2,-15)], ["fountain", Vector3(-3,1.2,2), Vector3(-4,.5,-1)], ["pavilion", Vector3(-18,1.8,19), Vector3(-22,1.0,21)], ["lodge", Vector3(-12,3.25,-15), Vector3(-11,2.6,-19)]]:
		camera.position = view[1]
		camera.look_at(view[2])
		for frame in range(120): await process_frame
		await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png(output.path_join(view[0]+".png")) == OK, "Render capture failed")
		var times: Array[float] = []
		var previous := Time.get_ticks_usec()
		for frame in range(120):
			await process_frame
			var now := Time.get_ticks_usec()
			times.append((now-previous)/1000.0)
			previous = now
		times.sort()
		samples.append({"view":view[0], "median_ms":times[60], "p95_ms":times[114], "texture_bytes":Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED), "streamed_bytes":TextureStreaming.get_memory_budget_bytes_used()})
	check(textures.size() == 9 and TextureStreaming.get_memory_budget_bytes_used() > 0, "Texture streaming never allocated world mipmaps")
	var report := {"renderer":RenderingServer.get_current_rendering_method(), "adapter":RenderingServer.get_video_adapter_name(), "viewport":str(root.size), "features":not baseline, "samples":samples}
	FileAccess.open(output.path_join("metrics.json"),FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
	print("RENDERING_UPGRADE_METRICS ",JSON.stringify(report))
	await scene.desktop_runtime.shutdown()
	print("RENDERING_UPGRADE_OK failures=", failures)
	quit(1 if failures else 0)
