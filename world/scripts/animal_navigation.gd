## Outdoor clearance graph. Rebuild from the location's ground/bounds, never from
## per-animal coordinates. Physics queries preserve narrow obstacles between cells.
extends Node3D

const STEP := 1.25
const RADII := [0.32, 0.9, 1.4]
const HEIGHT := 1.9
const BUILD_SLICE_US := 1500
var polygon := PackedVector2Array()
var sample_height: Callable
var ground_rids: Array[RID] = []
var graphs: Array[AStar3D] = []
var ready_for_paths := false
var generation := 0
var build_ms := 0
var path_requests := 0
var _shapes: Array[CylinderShape3D] = []
# Queries are synchronous on the main thread; results never survive an await.
var _ray_result := PhysicsIntersectRayResult3D.new()
var _clear_result := PhysicsIntersectShapeResult3D.new()
var _overlap_result := PhysicsIntersectShapeResult3D.new()
var _motion_result := PhysicsCastMotionResult3D.new()

func setup(boundary: PackedVector2Array, height: Callable, ground: Array[RID]) -> void:
	polygon = boundary
	sample_height = height
	ground_rids = ground
	_clear_result.max_intersections = 1
	_overlap_result.max_intersections = 8
	_shapes.clear()
	for radius in RADII:
		var shape := CylinderShape3D.new()
		shape.radius = radius
		shape.height = HEIGHT
		_shapes.append(shape)

func contains(p: Vector2, radius: float) -> bool:
	if not Geometry2D.is_point_in_polygon(p, polygon): return false
	for i in range(polygon.size()):
		if p.distance_to(Geometry2D.get_closest_point_to_segment(p, polygon[i], polygon[(i+1)%polygon.size()])) < radius + .12: return false
	return true

func surface(p: Vector2) -> Vector3:
	return Vector3(p.x, sample_height.call(p), p.y)

func outdoor(p: Vector3) -> bool:
	var query := PhysicsRayQueryParameters3D.create(p+Vector3.UP*30, p-Vector3.UP*.3, 1)
	if not get_world_3d().direct_space_state.intersect_ray_into(query, _ray_result): return false
	return _ray_result.collider_rid in ground_rids and _ray_result.normal.y > .88 and absf(_ray_result.position.y-p.y)<.08

func query_at(p: Vector3, profile: int, dynamic := false, exclude: Array = []) -> PhysicsShapeQueryParameters3D:
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = _shapes[profile]
	query.transform.origin = p + Vector3.UP*(HEIGHT*.5+.12)
	query.collision_mask = 23 if dynamic else 1
	var excluded: Array[RID] = ground_rids.duplicate()
	for rid in exclude: excluded.append(rid)
	query.exclude = excluded
	return query

func clear_at(p: Vector3, profile: int, dynamic := false, exclude: Array = []) -> bool:
	if not contains(Vector2(p.x,p.z),RADII[profile]): return false
	return not get_world_3d().direct_space_state.intersect_shape_into(query_at(p,profile,dynamic,exclude), _clear_result)

func segment_clear(a: Vector3, b: Vector3, profile: int, dynamic := false, exclude: Array = []) -> bool:
	var distance := Vector2(a.x-b.x,a.z-b.z).length()
	if distance > .001 and absf(a.y-b.y)/distance > .45: return false
	# Ground sample/containment at intermediate points prevents cutting across a
	# concave boundary, an indoor shortcut, or an unsupported terrain seam.
	for i in range(ceili(distance/.6)+1):
		var p := a.lerp(b,float(i)/maxi(1,ceili(distance/.6)))
		if not contains(Vector2(p.x,p.z),RADII[profile]): return false
		# Smoothing/steering must preserve the same exterior-only rule as graph
		# samples, including an open-sided roof over otherwise unobstructed ground.
		if not outdoor(surface(Vector2(p.x,p.z))): return false
	var query := query_at(a,profile,dynamic,exclude)
	query.motion = b-a
	var space := get_world_3d().direct_space_state
	var overlapping := space.intersect_shape_into(query, _overlap_result)
	for index in range(_overlap_result.get_intersection_count() if overlapping else 0):
		# A player or movable object can enter an animal's clearance envelope.
		# Permit an outward escape from that existing dynamic overlap; otherwise
		# the animal could never yield. Static penetration remains forbidden.
		var body: Node3D = _overlap_result.get_collider(index)
		if not dynamic or not (body is CharacterBody3D or body is RigidBody3D): return false
		var away := (a-body.global_position)*Vector3(1,0,1)
		if away.dot((b-a)*Vector3(1,0,1)) <= 0: return false
	return not space.cast_motion_into(query, _motion_result) or _motion_result.safe_fraction >= .999

func rebuild() -> void:
	ready_for_paths = false
	graphs.clear()
	var started := Time.get_ticks_msec()
	var bounds := Rect2(polygon[0],Vector2.ZERO)
	for p in polygon: bounds = bounds.expand(p)
	var first := Vector2i(floori(bounds.position.x/STEP),floori(bounds.position.y/STEP))
	var last := Vector2i(ceili(bounds.end.x/STEP),ceili(bounds.end.y/STEP))
	var terrain: Dictionary = {}
	var budget := 0
	var slice_started := Time.get_ticks_usec()
	for z in range(first.y,last.y+1):
		for x in range(first.x,last.x+1):
			var key := Vector2i(x,z)
			var p := surface(Vector2(key)*STEP)
			if contains(Vector2(p.x,p.z),RADII[0]) and outdoor(p): terrain[key] = p
			budget += 1
			if budget % 8 == 0 and Time.get_ticks_usec()-slice_started>=BUILD_SLICE_US:
				await get_tree().physics_frame
				slice_started=Time.get_ticks_usec()
	for profile in range(RADII.size()):
		var graph := AStar3D.new()
		var lookup: Dictionary = {}
		for key in terrain:
			var p: Vector3 = terrain[key]
			if clear_at(p,profile):
				var id := graph.get_point_count()
				graph.add_point(id,p)
				lookup[key] = id
			budget += 1
			if budget % 8 == 0 and Time.get_ticks_usec()-slice_started>=BUILD_SLICE_US:
				await get_tree().physics_frame
				slice_started=Time.get_ticks_usec()
		for key in lookup:
			for offset in [Vector2i(1,0),Vector2i(0,1),Vector2i(1,1),Vector2i(-1,1)]:
				var next: Vector2i = key+offset
				if not lookup.has(next): continue
				# No diagonal corner cutting, even where a small animal fits.
				if offset.x != 0 and offset.y != 0 and (not lookup.has(key+Vector2i(offset.x,0)) or not lookup.has(key+Vector2i(0,offset.y))): continue
				if segment_clear(terrain[key],terrain[next],profile): graph.connect_points(lookup[key],lookup[next])
			budget += 1
			if budget % 8 == 0 and Time.get_ticks_usec()-slice_started>=BUILD_SLICE_US:
				await get_tree().physics_frame
				slice_started=Time.get_ticks_usec()
		graphs.append(graph)
	generation += 1
	build_ms = Time.get_ticks_msec()-started
	ready_for_paths = true

func route(from: Vector3, to: Vector3, profile: int) -> PackedVector3Array:
	if not ready_for_paths: return PackedVector3Array()
	path_requests += 1
	var graph := graphs[profile]
	var start := graph.get_closest_point(from)
	var end := graph.get_closest_point(to)
	if start < 0 or end < 0: return PackedVector3Array()
	var a := graph.get_point_position(start)
	var b := graph.get_point_position(end)
	if a.distance_to(from)>STEP*1.6 or b.distance_to(to)>STEP*1.6 or not segment_clear(from,a,profile): return PackedVector3Array()
	var raw := graph.get_point_path(start,end)
	if raw.is_empty(): return raw
	# Visibility pruning produces long natural arcs instead of grid zigzags.
	var path := PackedVector3Array([from])
	var index := 0
	while index < raw.size():
		var furthest := index
		for j in range(index+1,mini(raw.size(),index+14)):
			if segment_clear(path[-1],raw[j],profile): furthest=j
		path.append(raw[furthest])
		index = furthest+1
	return path
