## Shared finish mapping for the original courtyard meshes, independent of apps.
extends RefCounted

const SURFACE = preload("res://scripts/village_surface.gdshader")
const COLORS := {
	"lime": Color("b1a695"), "ochre": Color("b7a38a"),
	"stone": Color("858986"), "cut_stone": Color("a4a497"),
	"wood": Color("765037"), "timber": Color("563829"),
	"slate": Color("536a85"), "tile": Color("536a85"),
	"glass": Color("253739"), "teal": Color("4b554b"),
	"terracotta": Color("a35539"), "soil": Color("373222"),
	"leaf": Color("367227"), "leaf_light": Color("648d32"), "leaf_dark": Color("244d23"),
}

static func apply(node: Node) -> void:
	if node is MeshInstance3D:
		for i in range(node.mesh.get_surface_count()):
			var original: StandardMaterial3D = node.mesh.surface_get_material(i)
			var label := original.resource_name
			var mat := ShaderMaterial.new()
			mat.shader = SURFACE
			mat.set_shader_parameter("base_color",COLORS.get(label,original.albedo_color))
			var kind := 0
			if label in ["wood","timber"]: kind=1
			elif label in ["stone","cut_stone"]: kind=2
			elif label in ["slate","tile"]: kind=3
			elif label.begins_with("roof"): kind=6
			elif label.begins_with("leaf") or label in ["pink","yellow","blue","petal_white"]: kind=4
			elif label in ["water","metal","glass"]: kind=5
			mat.set_shader_parameter("surface_kind",kind)
			mat.set_shader_parameter("surface_roughness",original.roughness)
			node.set_surface_override_material(i,mat)
	for child in node.get_children(): apply(child)
