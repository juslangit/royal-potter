extends Node3D
## The castle that grows out of the player's towers. It stands behind the wheel.
## The base is Codex's castle_base.glb; its empties socket_1 … socket_7 are where
## the finished towers stand, in the order they are made.

const TOWER_SCALE := 0.75          ## finished towers are shown a little smaller on the castle

var sockets: Array[Vector3] = []
var placed := 0


func _ready() -> void:
	var base := Toonify.load_model("res://assets/models/castle_base.glb")
	add_child(base)
	for i in range(1, 8):
		var s := base.find_child("socket_%d" % i, true, false) as Node3D
		sockets.append(to_local(s.global_position) if s else Vector3(i - 4, 0.3, 0))


## Put a finished tower on the castle: it drops in from above and bounces.
func place(tower_mesh: Mesh, glaze: Color) -> Node3D:
	var t := MeshInstance3D.new()
	t.mesh = tower_mesh
	t.material_override = Toonify.material(glaze, 0.0, 1.0)
	add_child(t)
	var target: Vector3 = sockets[placed % sockets.size()]
	t.position = target + Vector3(0, 4, 0)
	t.scale = Vector3.ONE * TOWER_SCALE
	var tw := create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tw.tween_property(t, "position", target, 0.9)
	placed += 1
	return t
