## Shared finish mapping for the original courtyard meshes, independent of apps.
extends RefCounted

const SURFACE = preload("res://scripts/village_surface.gdshader")
const COLORS := {
	"lime": Color("aaa99b"), "ochre": Color("989a90"),
	"stone": Color("737972"), "cut_stone": Color("96988c"),
	"wood": Color("69665b"), "timber": Color("373932"),
	"slate": Color("3f4b55"), "tile": Color("66554c"),
	"glass": Color("293537"), "teal": Color("505951"),
	"leaf": Color("557334"), "leaf_light": Color("7d9149"), "leaf_dark": Color("354d29"),
	"water": Color("627d80"), "water_jet": Color("bbcdd0"),
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
