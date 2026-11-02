## Independent map-growth/obstacle/clearance fixture using real physics geometry.
extends SceneTree
const Navigation = preload("res://scripts/animal_navigation.gd")
var failures:=0
func _initialize():call_deferred("run")
func check(ok:bool,message:String):
	if not ok:
		failures+=1
		push_error(message)
func box(parent:Node3D, position:Vector3, size:Vector3)->StaticBody3D:
	var body:=StaticBody3D.new();body.position=position
	var collider:=CollisionShape3D.new();var shape:=BoxShape3D.new();shape.size=size;collider.shape=shape
	body.add_child(collider);parent.add_child(body);return body
func run():
	var world:=Node3D.new();root.add_child(world)
	var floor_body:=box(world,Vector3(0,-.1,0),Vector3(40,.2,40))
	var nav:=Navigation.new();world.add_child(nav)
	var ground:Array[RID]=[floor_body.get_rid()]
	nav.setup(PackedVector2Array([Vector2(-8,-8),Vector2(8,-8),Vector2(8,8),Vector2(-8,8)]),func(_p):return 0.0,ground)
	await physics_frame
	await nav.rebuild()
	var before:=nav.graphs[0].get_point_count()
	check(nav.route(Vector3(-5,0,0),Vector3(5,0,0),0).size()>1,"Open route missing")
	check(nav.route(Vector3(-5,0,0),Vector3(13,0,0),0).is_empty(),"Unexpanded ground accepted")
	var roof:=box(world,Vector3(0,3,0),Vector3(3,.2,3))
	await physics_frame
	check(not nav.segment_clear(Vector3(-5,0,0),Vector3(5,0,0),0),"Path smoothing cut through a covered workspace")
	roof.queue_free();await physics_frame;await physics_frame
	# Add connected land and a new building across the former straight route.
	nav.polygon=PackedVector2Array([Vector2(-8,-8),Vector2(16,-8),Vector2(16,8),Vector2(-8,8)])
	var building:=box(world,Vector3(1,1.5,0),Vector3(3,3,6))
	await physics_frame
	await nav.rebuild()
	var route:=nav.route(Vector3(-5,0,0),Vector3(13,0,0),0)
	check(route.size()>2 and nav.graphs[0].get_point_count()>before,"Growth and new building did not update paths")
	var detour:=0.0
	for p in route:detour=maxf(detour,absf(p.z))
	check(detour>3.3,"Path cut through the new building")
	check(not nav.outdoor(Vector3(1,0,0)),"Building interior/roof admitted as outdoor ground")
	check(nav.route(Vector3(1,0,0),Vector3(13,0,0),0).is_empty(),"Indoor start silently snapped through wall")
	# A 1m-wide gate accepts chickens but rejects the cow clearance envelope.
	building.queue_free();await physics_frame;await physics_frame
	box(world,Vector3(0,1.5,-4.25),Vector3(1,3,7.5))
	box(world,Vector3(0,1.5,4.25),Vector3(1,3,7.5))
	await physics_frame
	await nav.rebuild()
	check(not nav.route(Vector3(-5,0,0),Vector3(5,0,0),0).is_empty(),"Chicken cannot use narrow gate")
	check(nav.route(Vector3(-5,0,0),Vector3(5,0,0),2).is_empty(),"Cow fitted through chicken-sized gate")
	# A player can enter the padded clearance circle. Escaping that overlap is
	# allowed only outward; this regresses the observed pair-of-goats deadlock.
	var player:=CharacterBody3D.new()
	player.collision_layer=2
	var collider:=CollisionShape3D.new()
	var capsule:=CapsuleShape3D.new();capsule.radius=.22;capsule.height=1.65
	collider.shape=capsule;collider.position.y=.825;player.add_child(collider)
	world.add_child(player);player.position=Vector3(-5.6,0,0)
	await physics_frame
	check(nav.segment_clear(Vector3(-5,0,0),Vector3(-4.8,0,0),1,true),"Cannot yield out of dynamic clearance overlap")
	check(not nav.segment_clear(Vector3(-5,0,0),Vector3(-5.2,0,0),1,true),"Movement deeper into dynamic overlap accepted")
	# Safe failures, including a completely occupied map.
	box(world,Vector3(0,1.5,0),Vector3(40,3,40));await physics_frame
	await nav.rebuild()
	check(nav.route(Vector3.ZERO,Vector3(5,0,0),0).is_empty(),"No-space path did not fail safely")
	print("ANIMAL_NAVIGATION_OK generations=",nav.generation," failures=",failures)
	quit(1 if failures else 0)
