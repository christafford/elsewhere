## Decorative distant terrain; no collision, movement or desktop services.
extends Node3D

func _ready() -> void:
	var material := ShaderMaterial.new()
	material.shader = preload("res://scripts/village_mountain.gdshader")
	for mesh in find_children("*", "MeshInstance3D"):
		mesh.material_override = material
