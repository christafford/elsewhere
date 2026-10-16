## Fixed courtyard planting from original geometry; no random runtime placement.
extends Node3D
const Landscape = preload("res://scripts/village_landscape.gd")
const Materials = preload("res://scripts/village_materials.gd")
# Keep the northwestern canopy clear of Lantern Inn's occupied upper floor.
const TREES := [Vector2(-22,-16),Vector2(-6,-27),Vector2(23,-23),Vector2(26,12),Vector2(-25,10),Vector2(15,26),Vector2(-29,-36),Vector2(31,-29)]

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

	# Low decorative borders sit beside facades, away from doors and routes.
	# No new collision or per-frame behavior; the walking surface is unchanged.
	for p in [Vector2(-16,-10.6), Vector2(-8.5,-10.6), Vector2(12,-12.4), Vector2(13.4,-5.4)]:
		var flowers: Node3D = preload("res://art/village/courtyard_flowers.glb").instantiate()
		flowers.name = "FlowerBorder"
		add_child(flowers)
		flowers.position = Vector3(p.x,Landscape.height_at(p)+.015,p.y)
		flowers.scale = Vector3.ONE * .8
		if p.x > 13: flowers.rotation.y = PI/2
		Materials.apply(flowers)
		# Tiny border shadows are lost at walking distance; avoid extra sun passes.
		for mesh in flowers.find_children("*", "MeshInstance3D"):
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
