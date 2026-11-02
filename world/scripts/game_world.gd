## First-person world navigation, suspended while application mode owns input.
extends CharacterBody3D

const WALK_SPEED := 4.0
const FAST_SPEED := 4.0
const SLOW_SPEED := 1.0
const JUMP_VELOCITY := 4.5
const LOOK_SENSITIVITY := 0.002
const DEFAULT_PITCH := -0.08
const SPAWN := Vector3(2.4, 0.05, 3.1)
const STEP_DISTANCE := 1.4
const BOB_RESPONSE := 12.0
@export var spawn_position := SPAWN
@export var spawn_yaw := 0.38
@export var spawn_pitch := DEFAULT_PITCH
@export_range(0.0, 0.05, 0.001) var head_bob_amplitude := 0.02
var slow_walk := false
var application_mode := false
var _held: Dictionary = {}
var _look_held := false
var _host_focused := true
var _bob_phase := 0.0
var _bob_weight := 0.0
@onready var camera: Camera3D = $Camera3D
@onready var _camera_rest_y: float = camera.position.y

func _ready() -> void:
	if "--no-head-bob" in OS.get_cmdline_user_args():
		head_bob_amplitude = 0.0
	return_to_spawn()

func return_to_spawn() -> void:
	release_pointer()
	position = spawn_position
	rotation = Vector3(0, spawn_yaw, 0)
	camera.rotation = Vector3(spawn_pitch, 0, 0)

func stop_looking() -> void:
	# Releasing the mouse changes input ownership, never the viewing direction.
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_look_held = false

func release_pointer() -> void:
	stop_looking()
	_held.clear()
	velocity = Vector3.ZERO
	_reset_head_bob()

func _reset_head_bob() -> void:
	_bob_phase = 0.0
	_bob_weight = 0.0
	camera.position.y = _camera_rest_y

func _update_head_bob(delta: float, distance: float, walking: bool) -> void:
	if head_bob_amplitude <= 0.0:
		_reset_head_bob()
		return
	# Use resolved ground travel: pushing into a wall must not march in place.
	var moving := walking and is_on_floor() and distance > 0.0001
	var target_weight := 0.0
	if moving:
		_bob_phase = fmod(_bob_phase + distance * TAU / STEP_DISTANCE, TAU)
		target_weight = minf(distance / delta / WALK_SPEED, 1.0)
	_bob_weight = lerpf(_bob_weight, target_weight, 1.0 - exp(-BOB_RESPONSE * delta))
	if not moving and _bob_weight < 0.001:
		_reset_head_bob()
		return
	# Camera translation only; collision height, pitch and application pixels stay stable.
	camera.position.y = _camera_rest_y + sin(_bob_phase) * head_bob_amplitude * _bob_weight

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_host_focused = false
		release_pointer()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_host_focused = true

func _input(event: InputEvent) -> void:
	# GUI controls may consume releases; always end input we already own.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed and _look_held:
		stop_looking()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and not event.pressed:
		var key: int = event.physical_keycode if event.physical_keycode else event.keycode
		_held.erase(key)

func _unhandled_input(event: InputEvent) -> void:
	if application_mode or not _host_focused:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		_look_held = event.pressed
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE
		get_viewport().set_input_as_handled()
	elif event is InputEventKey:
		if event.echo:
			return
		var key: int = event.physical_keycode if event.physical_keycode else event.keycode
		if key in [KEY_W, KEY_A, KEY_S, KEY_D, KEY_SHIFT, KEY_CTRL]:
			if event.pressed:
				_held[key] = true
			else:
				_held.erase(key)
		elif event.pressed and key == KEY_SPACE and is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif event.pressed and key == KEY_ESCAPE:
			release_pointer()
		elif event.pressed and key == KEY_HOME:
			return_to_spawn()
		elif event.pressed and key == KEY_M:
			slow_walk = not slow_walk
		else:
			return
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and _look_held and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation.y -= event.screen_relative.x * LOOK_SENSITIVITY
		camera.rotation.x = clampf(camera.rotation.x - event.screen_relative.y * LOOK_SENSITIVITY, -1.35, 1.35)
		get_viewport().set_input_as_handled()

func _physics_process(delta: float) -> void:
	if application_mode or not _host_focused:
		velocity = Vector3.ZERO
		_reset_head_bob()
		return
	var direction := Vector3(float(_held.has(KEY_D)) - float(_held.has(KEY_A)), 0, float(_held.has(KEY_S)) - float(_held.has(KEY_W)))
	# Walk on the floor relative to yaw, with equal cardinal/diagonal speed.
	direction = basis * direction.normalized()
	var speed := WALK_SPEED
	if slow_walk or _held.has(KEY_CTRL):
		speed = SLOW_SPEED
	elif _held.has(KEY_SHIFT):
		speed = FAST_SPEED
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	velocity.y -= 9.8 * delta
	var walking_velocity := velocity * Vector3(1, 0, 1)
	var previous_position := position
	move_and_slide()
	var travel := Vector2(position.x - previous_position.x, position.z - previous_position.z).length()
	_update_head_bob(delta, travel, not direction.is_zero_approx())
	for i in range(get_slide_collision_count()):
		var contact := get_slide_collision(i)
		var body := contact.get_collider()
		if body is RigidBody3D and body.is_in_group("pushable_furniture"):
			body.push(walking_velocity, contact.get_normal(), delta)
