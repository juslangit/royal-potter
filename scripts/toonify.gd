class_name Toonify
## Codex's models arrive with plain colour materials (named after the palette).
## This swaps every one for the game's toon material with outline, keeping the colour,
## so everything on screen shares one look. `recolor` maps a material name to a new
## colour (the visitors' "Body" is recoloured per visitor).

const TOON := preload("res://shaders/toon.gdshader")
const OUTLINE := preload("res://shaders/outline.gdshader")


static func load_model(path: String, recolor := {}) -> Node3D:
	var node: Node3D = load(path).instantiate()
	apply(node, recolor)
	return node


static func apply(node: Node, recolor := {}) -> void:
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		for s in mi.mesh.get_surface_count():
			var src := mi.mesh.surface_get_material(s)
			var color := Color.WHITE
			var mat_name := ""
			if src is BaseMaterial3D:
				color = (src as BaseMaterial3D).albedo_color
				mat_name = src.resource_name
			if recolor.has(mat_name):
				color = recolor[mat_name]
			mi.set_surface_override_material(s, material(color))
	for child in node.get_children():
		apply(child, recolor)


## One toon material with outline. Used by everything in the game.
static func material(color: Color, wet := 0.0, gloss := 0.0) -> ShaderMaterial:
	var outline := ShaderMaterial.new()
	outline.shader = OUTLINE
	var m := ShaderMaterial.new()
	m.shader = TOON
	m.set_shader_parameter("albedo", color)
	m.set_shader_parameter("wet", wet)
	m.set_shader_parameter("gloss", gloss)
	m.next_pass = outline
	return m
