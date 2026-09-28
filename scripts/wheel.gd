extends Node3D
## The wheel screen: an order comes in, the thumb shapes the clay, Done scores it.
## MVP — grey placeholder look; the customers, castle and art come later.

const Clay := preload("res://scripts/clay.gd")

const STAR_LEVELS := [0.60, 0.80, 0.92]   ## match needed for 1, 2, 3 stars
const GHOST_WIDTH := 0.022                ## thickness of the dotted outline

enum State { SHAPING, RESULT, COLLAPSED }

@onready var camera: Camera3D = $Camera
@onready var clay: Clay = $Clay
@onready var ghost: MeshInstance3D = $Ghost

var state := State.SHAPING
var tower: Dictionary
var tower_scale := 1.0
var tower_index := -1
var score := 0.0

# UI, built in _build_ui() so every size lives in one place.
var order_label: Label
var match_bar: ProgressBar
var match_label: Label
var wobble_bar: ProgressBar
var done_button: Button
var result_panel: PanelContainer
var result_title: Label
var result_stars: Label
var next_button: Button


func _ready() -> void:
	_build_ui()
	clay.collapsed.connect(_on_collapsed)
	_next_order()


func _process(_delta: float) -> void:
	if state == State.SHAPING:
		score = clay.match_score(tower.shape, tower.height, tower_scale)
		match_bar.value = score * 100.0
		match_label.text = "%d%%" % roundi(score * 100.0)
		wobble_bar.value = clay.wobble * 100.0


func _unhandled_input(event: InputEvent) -> void:
	if state != State.SHAPING:
		return
	if event is InputEventScreenTouch:
		clay.touching = event.pressed
		if event.pressed:
			_aim(event.position)
			Flow.blip(0.8)
	elif event is InputEventScreenDrag:
		_aim(event.position)


## Turn a finger position into "which height of the pot" and "how wide".
## The finger is projected onto the flat plane through the wheel's centre.
func _aim(screen_pos: Vector2) -> void:
	var from := camera.project_ray_origin(screen_pos)
	var dir := camera.project_ray_normal(screen_pos)
	if absf(dir.z) < 0.0001:
		return
	var p := from + dir * (-from.z / dir.z)
	clay.thumb_r = absf(p.x)
	clay.thumb_t = clampf(p.y / clay.height, 0.0, 1.0)


func _next_order() -> void:
	tower_index = (tower_index + 1) % Towers.LIST.size()
	tower = Towers.LIST[tower_index]
	tower_scale = Towers.width_scale(tower, clay.CLAY_AMOUNT, clay.RINGS)
	clay.reset()
	_build_ghost()
	order_label.text = "Order: %s" % tower.name
	result_panel.visible = false
	done_button.visible = true
	state = State.SHAPING


## The dotted outline of the wished tower: two thin ribbons, left and right.
func _build_ghost() -> void:
	var im := ImmediateMesh.new()
	im.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	var steps := 40
	for side in [-1.0, 1.0]:
		for i in steps:
			var t0 := float(i) / steps
			var t1 := float(i + 1) / steps
			var a := Vector3(side * Towers.width_at(tower.shape, t0) * tower_scale, t0 * tower.height, 0.0)
			var b := Vector3(side * Towers.width_at(tower.shape, t1) * tower_scale, t1 * tower.height, 0.0)
			var n := Vector3(b.y - a.y, -(b.x - a.x), 0).normalized() * GHOST_WIDTH
			im.surface_set_uv(Vector2(t0 * 4.0, 0)); im.surface_add_vertex(a - n)
			im.surface_set_uv(Vector2(t1 * 4.0, 0)); im.surface_add_vertex(b - n)
			im.surface_set_uv(Vector2(t1 * 4.0, 1)); im.surface_add_vertex(b + n)
			im.surface_set_uv(Vector2(t0 * 4.0, 0)); im.surface_add_vertex(a - n)
			im.surface_set_uv(Vector2(t1 * 4.0, 1)); im.surface_add_vertex(b + n)
			im.surface_set_uv(Vector2(t0 * 4.0, 1)); im.surface_add_vertex(a + n)
	im.surface_end()
	ghost.mesh = im


func _on_done() -> void:
	if state != State.SHAPING:
		return
	clay.touching = false
	var stars := 0
	for level in STAR_LEVELS:
		if score >= level:
			stars += 1
	state = State.RESULT
	Flow.blip(1.0 + stars * 0.25)
	result_title.text = ["Hmm…", "Not bad!", "Lovely!", "Perfect!"][stars]
	result_stars.text = "★".repeat(stars) + "☆".repeat(3 - stars) + "\n%d%% match" % roundi(score * 100.0)
	next_button.text = "NEXT ORDER"
	result_panel.visible = true
	done_button.visible = false


func _on_collapsed() -> void:
	state = State.COLLAPSED
	Flow.blip(0.5)
	result_title.text = "SPLOOSH!"
	result_stars.text = "The clay gave up.\nTry again?"
	next_button.text = "NEW CLAY"
	result_panel.visible = true
	done_button.visible = false


func _on_next() -> void:
	Flow.blip(1.2)
	if state == State.COLLAPSED:
		tower_index -= 1   # same order again
	_next_order()


# ---------------------------------------------------------------- UI

func _build_ui() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)

	var top := VBoxContainer.new()
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top.offset_left = 32; top.offset_right = -32; top.offset_top = 40
	top.add_theme_constant_override("separation", 10)
	ui.add_child(top)

	order_label = _label(44)
	top.add_child(order_label)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	top.add_child(row)
	var m := _label(30); m.text = "Match"; row.add_child(m)
	match_bar = _bar(Color("8fb996"))
	row.add_child(match_bar)
	match_label = _label(30); match_label.custom_minimum_size.x = 90; row.add_child(match_label)

	var row2 := HBoxContainer.new()
	row2.add_theme_constant_override("separation", 16)
	top.add_child(row2)
	var w := _label(30); w.text = "Wobble"; row2.add_child(w)
	wobble_bar = _bar(Color("e7727d"))
	row2.add_child(wobble_bar)

	done_button = _button("DONE")
	done_button.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	done_button.offset_top = -170; done_button.offset_bottom = -60
	done_button.offset_left = -170; done_button.offset_right = 170
	done_button.pressed.connect(_on_done)
	ui.add_child(done_button)

	result_panel = PanelContainer.new()
	result_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	result_panel.offset_left = -300; result_panel.offset_right = 300
	result_panel.offset_top = -260; result_panel.offset_bottom = 260
	var box := StyleBoxFlat.new()
	box.bg_color = Color("fbf5ec"); box.border_color = Color("2a2420")
	box.set_border_width_all(6); box.set_corner_radius_all(36)
	result_panel.add_theme_stylebox_override("panel", box)
	ui.add_child(result_panel)
	var rb := VBoxContainer.new()
	rb.alignment = BoxContainer.ALIGNMENT_CENTER
	rb.add_theme_constant_override("separation", 24)
	result_panel.add_child(rb)
	result_title = _label(64); rb.add_child(result_title)
	result_stars = _label(48); rb.add_child(result_stars)
	next_button = _button("NEXT ORDER")
	next_button.pressed.connect(_on_next)
	rb.add_child(next_button)
	result_panel.visible = false


func _label(size: int) -> Label:
	var l := Label.new()
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color("2a2420"))
	return l


func _bar(color: Color) -> ProgressBar:
	var b := ProgressBar.new()
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.custom_minimum_size.y = 36
	b.show_percentage = false
	var bg := StyleBoxFlat.new(); bg.bg_color = Color("eadccb"); bg.set_corner_radius_all(18)
	var fg := StyleBoxFlat.new(); fg.bg_color = color; fg.set_corner_radius_all(18)
	b.add_theme_stylebox_override("background", bg)
	b.add_theme_stylebox_override("fill", fg)
	return b


func _button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(340, 110)
	b.add_theme_font_size_override("font_size", 44)
	for state_name in ["normal", "hover", "pressed", "focus"]:
		var s := StyleBoxFlat.new()
		s.bg_color = Color("d9824f") if state_name != "pressed" else Color("a85a33")
		s.border_color = Color("2a2420"); s.set_border_width_all(6); s.set_corner_radius_all(55)
		b.add_theme_stylebox_override(state_name, s)
	b.add_theme_color_override("font_color", Color.WHITE)
	b.add_theme_color_override("font_pressed_color", Color.WHITE)
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	return b
