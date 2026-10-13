## Shared finish mapping for the original courtyard meshes, independent of apps.
extends RefCounted

const SURFACE = preload("res://scripts/village_surface.gdshader")
# Owner reference art-direction-1: sunlit plaster, clay roofs and warm oak.
const COLORS := {
	"lime": Color("d6c9ae"), "ochre": Color("cbbb93"),
	"stone": Color("9f977f"), "cut_stone": Color("ada58f"),
	"wood": Color("a27a51"), "timber": Color("714f33"),
	"slate": Color("a76637"), "tile": Color("b97643"),
	"roof0": Color("b67540"), "roof1": Color("c88950"),
	"roof2": Color("a96335"), "roof3": Color("d2965c"), "roof4": Color("bb7a46"),
	"glass": Color("3a514f"), "teal": Color("48786b"),
	"leaf": Color("578435"), "leaf_light": Color("7c9f48"), "leaf_dark": Color("365d2d"),
	"pink": Color("e46b9a"), "yellow": Color("efa836"), "blue": Color("dc793b"),
	"petal_white": Color("f3e7bf"), "terracotta": Color("b8764d"),
	"water": Color("568e91"), "water_jet": Color("c1dfe0"),
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
			elif label == "stone": kind=2
			elif label == "cut_stone": kind=8
			elif label in ["slate","tile"]: kind=3
			elif label.begins_with("roof"): kind=6
			elif label.begins_with("leaf") or label in ["pink","yellow","blue","petal_white"]: kind=4
			elif label in ["metal","glass"]: kind=5
			elif label in ["water","water_jet"]: kind=7
			if label in ["lime","ochre","wood","timber"]:
				var asset := "rough_wood" if kind==1 else "grey_plaster"
				for channel in ["diff","nor_gl","rough"]:
					mat.set_shader_parameter(channel+"_texture",load("res://art/village/textures/%s_%s_1k.jpg" % [asset,channel]))
				mat.set_shader_parameter("use_photo",true)
				mat.set_shader_parameter("photo_scale",2.0 if kind==1 else 1.0)
			mat.set_shader_parameter("surface_kind",kind)
			mat.set_shader_parameter("surface_roughness",original.roughness)
			node.set_surface_override_material(i,mat)
	for child in node.get_children(): apply(child)
