## P22-T12: location-owned second floors; existing character and desktop controls.
extends Node3D

const Architecture = preload("res://scripts/village_architecture.gd")
const Expansion = preload("res://scripts/village_expansion.gd")
const Materials = preload("res://scripts/village_materials.gd")
const FLOOR := 3.32
const RUN := 4.6
const WIDTH := 1.2

static func definitions() -> Array:
	return JSON.parse_string(FileAccess.get_file_as_string("res://art/village/upstairs.json"))

static func stair_points(spec: Dictionary) -> Array[Vector3]:
	var x: float = spec.width/2-1.0
	var start: float = spec.depth/2-.8
	return [Vector3(x,0,start),Vector3(x,FLOOR,start-RUN)]

func _ready() -> void:
	var helper := Architecture.new()
	var player: CharacterBody3D = get_parent().get_node("Player")
	for spec in definitions():
		var building: Node3D = get_parent().get_node(spec.path)
		var room: Node3D = load("res://art/village/upstairs_%s.glb" % spec.id.to_lower()).instantiate()
		room.name = "Upstairs"
		building.add_child(room)
		Materials.apply(room)
		helper.add_collision(room)
		var treads: Node3D = load("res://art/village/upstairs_%s_treads.glb" % spec.id.to_lower()).instantiate()
		treads.name = "StairTreads"
		room.add_child(treads)
		Materials.apply(treads)
		helper.add_collision(treads)
		# Objects land on the real treads; only the character uses the fitted guide.
		for body in treads.find_children("*","StaticBody3D",true,false):
			player.add_collision_exception_with(body)
		walking_guide(room,spec)
		var workspace := Node3D.new()
		workspace.name = "Workspace"
		workspace.position.y = FLOOR
		room.add_child(workspace)
		Expansion.worktable(workspace)
		var light := OmniLight3D.new()
		light.name = "UpstairsLight"
		light.position = Vector3(0,FLOOR+2.15,0)
		light.light_color = Color("ffe2ad")
		light.light_energy = 1.3
		light.omni_range = 6.5
		light.shadow_enabled = true
		room.add_child(light)
	helper.free()

func walking_guide(room: Node3D, spec: Dictionary) -> void:
	var points := stair_points(spec)
	var a := points[0]+Vector3(-WIDTH/2,0,0)
	var b := points[0]+Vector3(WIDTH/2,0,0)
	var c := points[1]+Vector3(WIDTH/2,0,0)
	var d := points[1]+Vector3(-WIDTH/2,0,0)
	var body := StaticBody3D.new()
	body.name = "StairWalkingGuide"
	body.collision_layer = 8
	body.collision_mask = 0
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(PackedVector3Array([a,d,c,a,c,b]))
	var collision := CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)
	room.add_child(body)
