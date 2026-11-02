## Injected movement regression; rendered captures do not establish human comfort.
extends SceneTree

const Landscape = preload("res://scripts/village_landscape.gd")
var failures := 0
var player: CharacterBody3D
var rest_y := 0.0
var output_dir := "res://../.tools/head-bob-test"

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func frames(count: int) -> void:
	for i in range(count): await physics_frame

func key(code: int, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	player._unhandled_input(event)

func reset() -> void:
	player.release_pointer()
	player.position = Vector3(0, 0.05, 12)
	player.rotation.y = 0
	await frames(15)

func capture(label: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(output_dir.path_join(label + ".png")) == OK, "Capture failed")

func run() -> void:
	var scene: Node3D = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	player = scene.get_node("Player")
	rest_y = player.camera.position.y
	output_dir = ProjectSettings.globalize_path(output_dir).simplify_path()
	DirAccess.make_dir_recursive_absolute(output_dir)
	await reset()
	await capture("idle")
	# Normal travel matches the former Shift pace; precision walking stays slow.
	for modifier in [0, KEY_SHIFT, KEY_CTRL, KEY_M]:
		await reset()
		if modifier: key(modifier, true)
		key(KEY_W, true)
		await frames(12)
		var expected := 1.0 if modifier in [KEY_CTRL, KEY_M] else 4.0
		check(is_equal_approx(Vector2(player.velocity.x, player.velocity.z).length(), expected), "Unexpected travel speed for modifier %s" % modifier)
		key(KEY_D, true)
		await frames(12)
		check(is_equal_approx(Vector2(player.velocity.x, player.velocity.z).length(), expected), "Diagonal travel changes speed")
		player.application_mode = true
		await frames(2)
		check(player.velocity.is_zero_approx(), "Application mode permits world movement")
		player.application_mode = false
		if modifier == KEY_M: key(KEY_M, true)
		if modifier: key(modifier, false)
		print("TRAVEL_SPEED_OK modifier=", modifier, " speed=", expected)
	var disabled := "--no-head-bob" in OS.get_cmdline_user_args()
	for code in [KEY_W, KEY_S, KEY_A, KEY_D]:
		await reset()
		var start := player.position
		var pitch: Vector3 = player.camera.rotation
		var low := 0.0
		var high := 0.0
		var captured_high := false
		var captured_low := false
		key(code, true)
		for i in range(100):
			await physics_frame
			var offset: float = player.camera.position.y - rest_y
			low = minf(low, offset)
			high = maxf(high, offset)
			if code == KEY_W and offset > 0.018 and not captured_high:
				captured_high = true
				await capture("walking-high")
			if code == KEY_W and offset < -0.018 and not captured_low:
				captured_low = true
				await capture("walking-low")
		key(code, false)
		check(player.position.distance_to(start) > 3.5, "Walking failed")
		var ground := Landscape.height_at(Vector2(player.position.x, player.position.z))
		check(absf(player.position.y - ground) < 0.01, "Bob moved collision body off the terrain")
		check(player.camera.rotation.is_equal_approx(pitch), "Bob changed viewing angle")
		check(low >= -0.0201 and high <= 0.0201, "Bob exceeded subtle amplitude")
		check((low == 0.0 and high == 0.0) if disabled else (low < -0.018 and high > 0.018), "Missing gait or disabled bob still moves")
		var stopped := player.position
		await frames(45)
		check(is_equal_approx(player.camera.position.y, rest_y) and player.position.distance_to(stopped) < 0.01, "Stop did not settle")
		print("HEAD_BOB_TRAVEL key=", code, " min=", low, " max=", high)
	# Collision-resolved movement, not held keys, controls the gait.
	var wall := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(8, 3, 0.3)
	shape.shape = box
	wall.add_child(shape)
	scene.add_child(wall)
	wall.position = Vector3(0, 1.5, 10)
	await reset()
	key(KEY_W, true)
	await frames(120)
	check(player.position.z > 10.3 and player.position.z < 10.5, "Wall collision failed")
	check(is_equal_approx(player.camera.position.y, rest_y), "Walking into a wall bobs in place")
	key(KEY_W, false)
	wall.queue_free()
	await reset()
	key(KEY_W, true)
	await frames(15)
	key(KEY_SPACE, true)
	key(KEY_SPACE, false)
	await frames(30)
	check(not player.is_on_floor() and absf(player.camera.position.y - rest_y) < 0.0001, "Airborne bob did not fade")
	player.application_mode = true
	await frames(2)
	check(is_equal_approx(player.camera.position.y, rest_y), "Application mode retains bob")
	player.application_mode = false
	await reset()
	key(KEY_D, true)
	await frames(12)
	player._notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(is_equal_approx(player.camera.position.y, rest_y) and player._held.is_empty(), "Focus loss retains bob/input")
	player._notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN)
	await reset()
	key(KEY_D, true)
	await frames(12)
	key(KEY_HOME, true)
	check(is_equal_approx(player.camera.position.y, rest_y) and player._held.is_empty(), "Home retains bob/input")
	await scene.desktop_runtime.shutdown()
	print("HEAD_BOB_OK mode=", DisplayServer.get_name(), " disabled=", disabled, " failures=", failures)
	quit(1 if failures else 0)
