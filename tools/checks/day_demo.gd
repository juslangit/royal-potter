extends SceneTree
## Visual check: plays the first visitor automatically — title, wish, shaping, glaze,
## kiln, reveal, placing on the castle — so the whole loop can be recorded:
##   Godot --path . -s tools/checks/day_demo.gd --write-movie out.png --fixed-fps 30

var game: Node
var t := 0.0
var step := 0


func _initialize() -> void:
	game = load("res://scenes/wheel.tscn").instantiate()
	root.add_child(game)


func _process(delta: float) -> bool:
	t += delta
	var clay = game.get_node("Clay")
	match step:
		0: if t > 1.0: game._start_day(); step += 1
		1: if t > 3.0: game._hear_wish(); step += 1
		2: if t > 4.5: game._start_shaping(); step += 1
		3:
			clay.touching = true
			clay.thumb_t = 0.5 + 0.5 * sin(t * 2.0)
			clay.thumb_r = 0.58
			if t > 8.0: clay.touching = false; step += 1
		4: if t > 8.5: game._on_done(); step += 1
		5: if t > 9.5: game._pick_glaze("sky_spire"); step += 1
		6: if t > 10.5: game._fire(); step += 1
		7: if t > 14.0: game._place(); step += 1
		8: if t > 20.0: return true
	return false
