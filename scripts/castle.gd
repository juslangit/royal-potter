extends Node3D
## The castle that grows out of the player's towers. It stands behind the wheel.
## Placeholder walls for now; Codex's castle_base.glb replaces them later
## (its socket_1 … socket_7 empties give the tower spots).

const TOON := preload("res://shaders/toon.gdshader")
const OUTLINE := preload("res://shaders/outline.gdshader")

const TOWER_SCALE := 0.75          ## finished towers are shown a little smaller on the castle
const SOCKETS := [                 ## where towers stand, in the order they are made
	Vector3(-1.9, 0.35, 0.6), Vector3(1.9, 0.35, 0.6), Vector3(0.0, 0.35, 0.9),
	Vector3(-1.1, 0.35, -0.6), Vector3(1.1, 0.35, -0.6), Vector3(-2.4, 0.35, -1.2),
	Vector3(0.0, 0.35, -1.3),
]

var placed := 0


func _ready() -> void:
	_build_placeholder()


func socket(i: int) -> Vector3:
	return to_global(SOCKETS[clampi(i, 0, SOCKETS.size() - 1)])


## Put a finished tower on the castle: it drops in from above and bounces.
func place(tower_mesh: Mesh, glaze: Color) -> Node3D:
	var t := MeshInstance3D.new()
	t.mesh = tower_mesh
	t.material_override = material(glaze, 0.0, 1.0)
	add_child(t)
	var target: Vector3 = SOCKETS[placed % SOCKETS.size()]
	t.position = target + Vector3(0, 4, 0)
	t.scale = Vector3.ONE * TOWER_SCALE
	var tw := create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tw.tween_property(t, "position", target, 0.9)
	placed += 1
	return t


## One toon material with outline. Shared by everything in the game that is built in code.
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


func _build_placeholder() -> void:
	var plaster := material(Color("f0d6ae"))
	var ground := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = 3.6; disc.bottom_radius = 3.8; disc.height = 0.35
	ground.mesh = disc
	ground.position.y = 0.175
	ground.material_override = material(Color("c9a77c"))
	add_child(ground)
	# A ring of low crenellated wall around the edge.
	for i in 28:
		var a := TAU * i / 28.0
		var block := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.7, 0.5 if i % 2 == 0 else 0.34, 0.3)
		block.mesh = box
		block.position = Vector3(cos(a) * 3.5, 0.35 + box.size.y / 2.0, sin(a) * 3.5)
		block.rotation.y = -a + PI / 2.0
		block.material_override = plaster
		add_child(block)
