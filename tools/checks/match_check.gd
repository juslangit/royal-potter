extends SceneTree
## Headless check: for every tower, can a perfect pot score ~100%, and does a
## fresh lump score low? Run:
##   Godot --headless --path . -s tools/checks/match_check.gd

const Clay := preload("res://scripts/clay.gd")


func _init() -> void:
	var clay: Clay = Clay.new()
	clay.reset()
	var ok := true
	for tower in Towers.LIST:
		var sc := Towers.width_scale(tower, Clay.CLAY_AMOUNT, Clay.RINGS)
		clay.reset()
		var lump := clay.match_score(tower.shape, tower.height, sc)
		# Make the perfect pot: copy the wish's widths into the clay.
		for i in Clay.RINGS:
			clay.radii[i] = Towers.width_at(tower.shape, float(i) / (Clay.RINGS - 1)) * sc
		clay._update_height()
		var perfect := clay.match_score(tower.shape, tower.height, sc)
		var widest := 0.0
		for w in tower.shape:
			widest = maxf(widest, w * sc)
		print("%-11s lump %3d%%  perfect %3d%%  height %.2f (wants %.2f)  widest %.2f" % [
			tower.name, lump * 100, perfect * 100, clay.height, tower.height, widest])
		if perfect < 0.95 or lump > 0.8:
			ok = false
	print("RESULT: ", "PASS" if ok else "FAIL")
	clay.free()
	quit()
