## Compare reusable query results with the legacy API, including stale misses.
extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func run() -> void:
	var scene := Node3D.new()
	root.add_child(scene)
	var body := StaticBody3D.new()
	var collision := CollisionShape3D.new()
	collision.shape = BoxShape3D.new()
	body.add_child(collision)
	scene.add_child(body)
	await physics_frame
	await physics_frame
	var space := scene.get_world_3d().direct_space_state
	var ray := PhysicsIntersectRayResult3D.new()
	var overlap := PhysicsIntersectShapeResult3D.new()
	overlap.max_intersections = 1
	var motion := PhysicsCastMotionResult3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.2
	# A miss after a hit must not re-use the old collider or blocked fraction.
	for x in [0.0, 10.0, 0.0, 10.0]:
		var rq := PhysicsRayQueryParameters3D.create(Vector3(x, 3, 0), Vector3(x, -3, 0), 1)
		var old_ray := space.intersect_ray(rq)
		var hit := space.intersect_ray_into(rq, ray)
		check(hit == not old_ray.is_empty(), "Ray hit/miss differs")
		if hit:
			check(ray.collider_rid == old_ray.rid and ray.position.is_equal_approx(old_ray.position) and ray.normal.is_equal_approx(old_ray.normal), "Ray fields differ")
		var sq := PhysicsShapeQueryParameters3D.new()
		sq.shape = shape
		sq.transform.origin = Vector3(x, 0, 0)
		sq.collision_mask = 1
		var old_overlap := space.intersect_shape(sq, 1)
		var overlaps := space.intersect_shape_into(sq, overlap)
		check(overlaps == not old_overlap.is_empty(), "Overlap hit/miss differs")
		if overlaps:
			check(overlap.get_intersection_count() == 1 and overlap.get_collider(0) == body, "Overlap limit/collider differs")
		sq.transform.origin = Vector3(x, 3, 0)
		sq.motion = Vector3(0, -6, 0)
		var old_motion := space.cast_motion(sq)
		var cast := space.cast_motion_into(sq, motion)
		check((not cast or motion.safe_fraction >= .999) == (old_motion[0] >= .999), "Motion clearance differs after hit/miss")
		if cast: check(is_equal_approx(motion.safe_fraction, old_motion[0]), "Motion safe fraction differs")
		# Exclusion masks retain their original meaning with reused results.
		rq.exclude = [body.get_rid()]
		check(not space.intersect_ray_into(rq, ray), "Ray exclusion ignored")
		sq.transform.origin = Vector3.ZERO
		sq.exclude = [body.get_rid()]
		check(not space.intersect_shape_into(sq, overlap), "Shape exclusion ignored")
	print("GODOT48_QUERIES_OK cases=4 failures=", failures)
	scene.queue_free()
	await process_frame
	quit(1 if failures else 0)
