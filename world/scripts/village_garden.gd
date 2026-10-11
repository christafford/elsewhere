## Fixed courtyard planting from original geometry; no random runtime placement.
extends Node3D
const Landscape = preload("res://scripts/village_landscape.gd")
const Materials = preload("res://scripts/village_materials.gd")
const TREES := [Vector2(-22,-16),Vector2(-6,-27),Vector2(23,-23),Vector2(26,12),Vector2(-25,10),Vector2(15,26),Vector2(-29,-32),Vector2(31,-29)]

func _ready() -> void:
	for i in range(TREES.size()):
		var p: Vector2 = TREES[i]
		var tree: Node3D = preload("res://art/village/courtyard_tree.glb").instantiate()
		tree.name = "CourtyardTree%s" % i
		add_child(tree)
		tree.position = Vector3(p.x,Landscape.height_at(p),p.y)
		tree.rotation.y = i*1.37
		Materials.apply(tree)
		# Leaves/branches are decorative; only the substantial trunk blocks walking.
		var body := StaticBody3D.new()
		var collider := CollisionShape3D.new()
		var shape := CylinderShape3D.new()
		shape.radius = 0.31
		shape.height = 3.6
		collider.shape = shape
		collider.position.y = 1.8
		tree.add_child(body)
		body.add_child(collider)
		body.add_to_group("village_architecture_collision")
