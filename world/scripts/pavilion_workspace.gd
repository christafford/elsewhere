## Location-owned furniture; anchors are physical supports, never app identities.
extends Node3D

const Materials = preload("res://scripts/village_materials.gd")
const Furniture = preload("res://scripts/pushable_furniture.gd")

func _ready() -> void:
	for side in [-1, 1]:
		var label := "West" if side < 0 else "East"
		var table := StaticBody3D.new()
		table.name = label + "Worktable"
		add_child(table)
		table.position = Vector3(side * 2.0, 0, -1.9)
		table.add_to_group("village_workspace_collision")
		var model: Node3D = preload("res://art/village/pavilion_worktable.glb").instantiate()
		table.add_child(model)
		Materials.apply(model)
		box(table, Vector3(2.52, 0.12, 1.04), Vector3(0, 0.90, 0))
		box(table, Vector3(1.8, 0.03, 0.62), Vector3(0, 0.965, 0.02))
		for x in [-0.9, 0.9]:
			box(table, Vector3(0.22, 0.85, 0.95), Vector3(x, 0.425, 0))
		var anchor := Marker3D.new()
		anchor.name = "WorkAnchor"
		table.add_child(anchor)
		# The +Z working side looks north across the entrance toward the square.
		anchor.position = Vector3(0, 0.98, 0.02)
		var stool := Furniture.new()
		stool.name = label + "Stool"
		stool.kind = "assembly"
		stool.assembly_mass = 6.0
		add_child(stool)
		stool.position = Vector3(side * 2.0, 0.04, 0.3)
		stool.add_to_group("village_workspace_collision")
		var seat: Node3D = preload("res://art/village/pavilion_stool.glb").instantiate()
		stool.add_child(seat)
		Materials.apply(seat)
		stool.shape(Vector3(0.70, 0.09, 0.70), Vector3(0, 0.535, 0))
		for x in [-0.21, 0.21]:
			for z in [-0.21, 0.21]: stool.shape(Vector3(0.075, 0.50, 0.075), Vector3(x, 0.25, z))
		stool.measure_visuals()

func box(body: StaticBody3D, size: Vector3, center: Vector3) -> void:
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	collision.position = center
