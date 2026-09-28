extends MeshInstance3D
## The clay on the wheel.
##
## The whole pot is one list of widths (`radii`), bottom to top. Every frame the list
## is spun into a round 3D mesh, like a lathe. The thumb changes the numbers; the same
## list is used for the score, the wobble and (later) the copy placed on the castle.
##
## Clay keeps its amount: squeeze it thinner and it rises taller, widen it and it sinks.

signal collapsed

# --- Feel. Every number that changes how shaping feels lives here. ---
const RINGS := 28              ## how many widths make up the pot (more = smoother)
const SIDES := 36              ## how round it is
const CLAY_AMOUNT := 0.95      ## total clay (volume). Decides how tall towers get
const START_RADIUS := 0.58     ## width of the fresh lump
const MIN_RADIUS := 0.10       ## clay never gets thinner than this
const MAX_RADIUS := 0.85       ## or wider than this
const MIN_HEIGHT := 0.45
const MAX_HEIGHT := 2.9
const SHAPE_SPEED := 6.0       ## how fast clay follows the thumb (higher = snappier)
const THUMB_SPREAD := 2.2      ## how many rings one thumb touches (soft brush size)
const SMOOTHING := 0.9         ## gentle smoothing so it never looks jagged
const SPIN_SPEED := 9.0        ## radians per second, just for looks

# Wobble: thin walls and big overhangs make the pot wobble, until it goes sploosh.
const THIN_RADIUS := 0.16      ## thinner than this is risky
const OVERHANG := 0.09         ## a ring wider than the one below by this is risky
const WOBBLE_RISE := 0.55      ## wobble per second while something is risky
const WOBBLE_FALL := 0.35      ## wobble lost per second while all is fine

var radii := PackedFloat32Array()
var height := 1.0
var wobble := 0.0
var touching := false
var thumb_t := 0.5             ## where on the pot the thumb is, 0 = base, 1 = rim
var thumb_r := 0.5             ## the width the thumb asks for
var alive := true
var frozen := false          ## true once the player taps Done: it only spins

var _spin := 0.0
var _time := 0.0


func _ready() -> void:
	reset()


func reset() -> void:
	radii.resize(RINGS)
	for i in RINGS:
		var t := float(i) / (RINGS - 1)
		# A soft lump: full width, rounding off at the top.
		radii[i] = START_RADIUS * (1.0 - 0.35 * pow(t, 3.0))
	wobble = 0.0
	alive = true
	frozen = false
	rotation = Vector3.ZERO
	scale = Vector3.ONE
	_update_height()
	_rebuild()


func _process(delta: float) -> void:
	_time += delta
	_spin = fmod(_spin + SPIN_SPEED * delta, TAU)
	if not alive:
		return
	if frozen:
		rotation.y = _spin
		return
	if touching:
		_shape(delta)
	_smooth(delta)
	_update_height()
	_update_wobble(delta)
	_rebuild()
	# A wobbling pot sways on the wheel.
	rotation = Vector3(sin(_time * 7.0) * wobble * 0.12, _spin, cos(_time * 6.0) * wobble * 0.12)


## Pull every ring near the thumb towards the width the thumb asks for.
func _shape(delta: float) -> void:
	var centre := thumb_t * (RINGS - 1)
	var target := clampf(thumb_r, MIN_RADIUS, MAX_RADIUS)
	for i in RINGS:
		var d := (i - centre) / THUMB_SPREAD
		var w := exp(-d * d)
		radii[i] = lerpf(radii[i], target, clampf(SHAPE_SPEED * w * delta, 0.0, 1.0))


func _smooth(delta: float) -> void:
	var copy := radii.duplicate()
	var k := clampf(SMOOTHING * delta, 0.0, 0.5)
	for i in range(1, RINGS - 1):
		radii[i] = lerpf(copy[i], (copy[i - 1] + copy[i + 1]) * 0.5, k)


## Height follows from the amount of clay: volume = sum of ring areas × ring spacing.
func _update_height() -> void:
	var area := 0.0
	for r in radii:
		area += PI * r * r
	area /= RINGS
	height = clampf(CLAY_AMOUNT / maxf(area, 0.001), MIN_HEIGHT, MAX_HEIGHT)


func _update_wobble(delta: float) -> void:
	var risky := false
	for i in RINGS:
		if radii[i] < THIN_RADIUS and i < RINGS - 3:
			risky = true
		if i > 0 and radii[i] - radii[i - 1] > OVERHANG:
			risky = true
	wobble = clampf(wobble + (WOBBLE_RISE if risky else -WOBBLE_FALL) * delta, 0.0, 1.0)
	if wobble >= 1.0:
		_collapse()


func _collapse() -> void:
	alive = false
	touching = false
	collapsed.emit()
	var tw := create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector3(1.5, 0.28, 1.5), 0.6)
	tw.parallel().tween_property(self, "rotation:x", 0.25, 0.6)


## Width of the pot at a height given as 0..1 of its own height.
func radius_at(t: float) -> float:
	var f := clampf(t, 0.0, 1.0) * (RINGS - 1)
	var i := int(floor(f))
	if i >= RINGS - 1:
		return radii[RINGS - 1]
	return lerpf(radii[i], radii[i + 1], f - i)


## How close this pot is to a tower wish, 0..1. Compares widths at 24 heights in
## real units, so a tower that is too short or too tall loses points too.
func match_score(shape: Array, shape_height: float, shape_scale: float) -> float:
	var top := maxf(height, shape_height)
	var err := 0.0
	var samples := 24
	for s in samples:
		var y := (s + 0.5) / samples * top
		var mine := radius_at(y / height) if y <= height else 0.0
		var want := 0.0
		if y <= shape_height:
			want = Towers.width_at(shape, y / shape_height) * shape_scale
		err += absf(mine - want)
	err /= samples
	return clampf(1.0 - err / 0.22, 0.0, 1.0)


## Spin the list of widths into a round mesh: sides, a rim, and a dark opening on top.
func _rebuild() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_color(Color.WHITE)
	var dy := height / (RINGS - 1)
	for i in RINGS - 1:
		var y0 := i * dy
		var y1 := (i + 1) * dy
		for s in SIDES:
			var a0 := TAU * s / SIDES
			var a1 := TAU * (s + 1) / SIDES
			var p00 := Vector3(cos(a0) * radii[i], y0, sin(a0) * radii[i])
			var p01 := Vector3(cos(a1) * radii[i], y0, sin(a1) * radii[i])
			var p10 := Vector3(cos(a0) * radii[i + 1], y1, sin(a0) * radii[i + 1])
			var p11 := Vector3(cos(a1) * radii[i + 1], y1, sin(a1) * radii[i + 1])
			var slope := (radii[i] - radii[i + 1]) / dy
			var n0 := Vector3(cos(a0), slope, sin(a0)).normalized()
			var n1 := Vector3(cos(a1), slope, sin(a1)).normalized()
			st.set_uv(Vector2(float(s) / SIDES, float(i) / RINGS))
			st.set_normal(n0); st.add_vertex(p00)
			st.set_normal(n1); st.add_vertex(p01)
			st.set_normal(n1); st.add_vertex(p11)
			st.set_normal(n0); st.add_vertex(p00)
			st.set_normal(n1); st.add_vertex(p11)
			st.set_normal(n0); st.add_vertex(p10)
	# Top: a flat rim ring and a darker dip, so it reads as a pot, not a solid.
	var rt := radii[RINGS - 1]
	var inner := rt * 0.72
	for s in SIDES:
		var a0 := TAU * s / SIDES
		var a1 := TAU * (s + 1) / SIDES
		var o0 := Vector3(cos(a0) * rt, height, sin(a0) * rt)
		var o1 := Vector3(cos(a1) * rt, height, sin(a1) * rt)
		var i0 := Vector3(cos(a0) * inner, height, sin(a0) * inner)
		var i1 := Vector3(cos(a1) * inner, height, sin(a1) * inner)
		var dip := Vector3(0, height - rt * 0.5, 0)
		st.set_color(Color.WHITE)
		st.set_normal(Vector3.UP)
		st.add_vertex(o0); st.add_vertex(o1); st.add_vertex(i1)
		st.add_vertex(o0); st.add_vertex(i1); st.add_vertex(i0)
		st.set_color(Color(0.45, 0.3, 0.22))   # the inside of the pot is in shadow
		st.add_vertex(i0); st.add_vertex(i1); st.add_vertex(dip)
	mesh = st.commit()
