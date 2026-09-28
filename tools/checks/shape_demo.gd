extends SceneTree
## Visual check: a fake thumb squeezes the lump into a tall tower, sweeping up and down.
##   Godot --path . -s tools/checks/shape_demo.gd --write-movie out.png --fixed-fps 30

var wheel: Node
var t := 0.0


func _initialize() -> void:
	wheel = load("res://scenes/wheel.tscn").instantiate()
	root.add_child(wheel)


func _process(delta: float) -> bool:
	t += delta
	var clay = wheel.get_node("Clay")
	clay.touching = t > 0.5 and t < 5.5
	clay.thumb_t = 0.5 + 0.5 * sin(t * 2.2)       # sweep up and down the pot
	clay.thumb_r = 0.34                            # squeeze towards a slim tower
	return t > 6.5
