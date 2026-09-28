extends Node3D
## The whole game: a day in the royal potter's courtyard.
##
##   title → visitor arrives → shape the tower → pick a glaze → fire → reveal
##         → the tower flies onto the castle → next visitor … → the dragon → the end
##
## The clay itself lives in clay.gd, the castle in castle.gd, the visitors' words
## in data/customers.json (see visitors.gd).

const Clay := preload("res://scripts/clay.gd")
const Castle := preload("res://scripts/castle.gd")

# --- Tuning ---
const STAR_LEVELS := [0.60, 0.80, 0.92]    ## match needed for 1, 2, 3 stars
const GHOST_WIDTH := 0.022                 ## thickness of the dotted outline
const WET_CLAY := Color("ad5c37")
const FIRE_TIME := 1.6                     ## seconds in the kiln
const CAMERA_MOVE := 1.1                   ## seconds for the camera to swing to the castle
const CASTLE_POS := Vector3(0, 0, -9)
const VISITOR_POS := Vector3(1.55, 0, -1.0)
const VISITOR_COLORS := [Color("7ba2da"), Color("b2675d"), Color("959b68"), Color("f2b345"), Color("f0d6ae"), Color("9f683b"), Color("959b68")]

enum State { TITLE, ARRIVE, SHAPING, GLAZE, FIRING, REVEAL, PLACING, COLLAPSED, END }

@onready var camera: Camera3D = $Camera
@onready var clay: Clay = $Clay
@onready var ghost: MeshInstance3D = $Ghost

var state := State.TITLE
var day: Dictionary
var visitor: Dictionary
var visitor_index := -1
var tower: Dictionary
var tower_scale := 1.0
var score := 0.0
var stars := 0
var total_stars := 0
var glaze_id := ""

var wheel_view: Transform3D
var castle_view: Transform3D
var castle: Castle
var bean: Node3D

# UI (built in code, see the bottom of this file, so every size lives in one place)
var ui: CanvasLayer
var bubble: PanelContainer
var bubble_name: Label
var bubble_text: Label
var bars: VBoxContainer
var match_bar: ProgressBar
var match_label: Label
var wobble_bar: ProgressBar
var glaze_row: HBoxContainer
var main_button: Button
var big_text: Label
var hud: Label
var title_panel: PanelContainer
var title_intro: Label
var end_panel: PanelContainer
var end_text: Label


func _ready() -> void:
	day = Visitors.load_day()
	wheel_view = camera.transform
	castle_view = Transform3D(Basis(), CASTLE_POS + Vector3(0, 3.0, 6.2)).looking_at(CASTLE_POS + Vector3(0, 1.1, 0))
	castle = Castle.new()
	castle.position = CASTLE_POS
	add_child(castle)
	clay.collapsed.connect(_on_collapsed)
	_build_ui()
	_show_title()


func _process(_delta: float) -> void:
	if state == State.SHAPING:
		score = clay.match_score(tower.shape, tower.height, tower_scale)
		match_bar.value = score * 100.0
		match_label.text = "%d%%" % roundi(score * 100.0)
		wobble_bar.value = clay.wobble * 100.0


func _unhandled_input(event: InputEvent) -> void:
	if state == State.TITLE:
		if event is InputEventScreenTouch and event.pressed:
			Flow.blip()   # the first tap also wakes up the sound
			_start_day()
		return
	if state != State.SHAPING:
		return
	if event is InputEventScreenTouch:
		if event.pressed and _over_button(event.position):
			return
		clay.touching = event.pressed
		if event.pressed:
			_aim(event.position)
	elif event is InputEventScreenDrag:
		_aim(event.position)


## Finger position → "which height of the pot" and "how wide", on the flat plane
## through the wheel's centre.
func _aim(screen_pos: Vector2) -> void:
	var from := camera.project_ray_origin(screen_pos)
	var dir := camera.project_ray_normal(screen_pos)
	if absf(dir.z) < 0.0001:
		return
	var p := from + dir * (-from.z / dir.z)
	clay.thumb_r = absf(p.x)
	clay.thumb_t = clampf(p.y / clay.height, 0.0, 1.0)


func _over_button(pos: Vector2) -> bool:
	return main_button.visible and main_button.get_global_rect().has_point(pos)


# ---------------------------------------------------------------- the day

func _show_title() -> void:
	state = State.TITLE
	camera.transform = castle_view
	clay.visible = false
	title_intro.text = day.intro
	title_panel.visible = true


func _start_day() -> void:
	title_panel.visible = false
	total_stars = 0
	visitor_index = -1
	_move_camera(wheel_view)
	_next_visitor()


func _next_visitor() -> void:
	visitor_index += 1
	if visitor_index >= day.visitors.size():
		_end_day()
		return
	visitor = day.visitors[visitor_index]
	tower = Visitors.tower_for(visitor)
	tower_scale = Towers.width_scale(tower, Clay.CLAY_AMOUNT, Clay.RINGS)
	state = State.ARRIVE
	_reset_clay()
	ghost.visible = false
	glaze_row.visible = false
	bars.visible = false
	big_text.visible = false
	_spawn_visitor()
	_say(visitor.arrive if visitor_index > 0 else "%s\n%s" % [day.day_start, visitor.arrive])
	_update_hud()
	_button("I'M LISTENING", _hear_wish)


func _hear_wish() -> void:
	_say(visitor.wish)
	_button("START THROWING", _start_shaping)


func _start_shaping() -> void:
	state = State.SHAPING
	_build_ghost()
	ghost.visible = true
	bars.visible = true
	big_text.visible = false
	_say(visitor.wish)
	_button("DONE", _on_done)


func _on_done() -> void:
	clay.touching = false
	clay.frozen = true
	stars = 0
	for level in STAR_LEVELS:
		if score >= level:
			stars += 1
	state = State.GLAZE
	ghost.visible = false
	bars.visible = false
	glaze_row.visible = true
	glaze_id = ""
	_say("Now pick a glaze!")
	main_button.visible = false
	Flow.blip(1.1)


func _pick_glaze(id: String) -> void:
	glaze_id = id
	Flow.blip(1.3)
	clay.material_override = Castle.material(Visitors.GLAZES[id].color, 0.3)
	_button("FIRE THE KILN", _fire)


func _fire() -> void:
	state = State.FIRING
	glaze_row.visible = false
	main_button.visible = false
	_say("…")
	Flow.blip(0.6)
	# The kiln: the screen glows warm and the pot shivers, then it comes out glossy.
	var glow := ColorRect.new()
	glow.color = Color(1.0, 0.62, 0.2, 0.0)
	glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(glow)
	var tw := create_tween()
	tw.tween_property(glow, "color:a", 0.85, FIRE_TIME * 0.5)
	tw.tween_callback(func(): clay.material_override = Castle.material(Visitors.GLAZES[glaze_id].color, 0.0, 1.0))
	tw.tween_property(glow, "color:a", 0.0, FIRE_TIME * 0.5)
	tw.tween_callback(glow.queue_free)
	tw.tween_callback(_reveal)


func _reveal() -> void:
	state = State.REVEAL
	total_stars += stars
	var loved: bool = glaze_id == visitor.get("glaze_hint", "")
	_say(visitor.react[stars] + ("\n♥ They love the glaze!" if loved else ""))
	big_text.text = "★".repeat(stars) + "☆".repeat(3 - stars)
	big_text.visible = true
	big_text.scale = Vector2(0.2, 0.2)
	big_text.pivot_offset = big_text.size / 2.0
	create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).tween_property(big_text, "scale", Vector2.ONE, 0.5)
	Flow.blip(1.0 + stars * 0.3)
	_update_hud()
	_button("ADD TO THE CASTLE", _place)


func _place() -> void:
	state = State.PLACING
	main_button.visible = false
	big_text.visible = false
	bubble.visible = false
	var finished: Mesh = clay.mesh
	var glaze: Color = Visitors.GLAZES[glaze_id].color
	clay.visible = false
	_leave_visitor()
	_move_camera(castle_view)
	var tw := create_tween()
	tw.tween_interval(CAMERA_MOVE)
	tw.tween_callback(func(): castle.place(finished, glaze); Flow.blip(0.9))
	tw.tween_interval(1.4)
	tw.tween_callback(func(): _move_camera(wheel_view))
	tw.tween_interval(CAMERA_MOVE)
	tw.tween_callback(_next_visitor)


func _on_collapsed() -> void:
	state = State.COLLAPSED
	ghost.visible = false
	bars.visible = false
	big_text.text = "SPLOOSH!"
	big_text.visible = true
	_say(visitor.sploosh)
	Flow.blip(0.5)
	_button("NEW CLAY", func(): _reset_clay(); _start_shaping())


func _end_day() -> void:
	state = State.END
	bubble.visible = false
	main_button.visible = false
	_move_camera(castle_view)
	end_text.text = "%s\n\n★ %d / %d" % ["\n".join(day.ending), total_stars, day.visitors.size() * 3]
	var tw := create_tween()
	tw.tween_interval(CAMERA_MOVE)
	tw.tween_callback(func(): end_panel.visible = true)


func _reset_clay() -> void:
	clay.visible = true
	clay.material_override = Castle.material(WET_CLAY, 1.0)
	clay.reset()


func _move_camera(to: Transform3D) -> void:
	create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).tween_property(camera, "transform", to, CAMERA_MOVE)


# ---------------------------------------------------------------- visitors (placeholder beans)

func _spawn_visitor() -> void:
	if bean:
		bean.queue_free()
	bean = Node3D.new()
	var body := MeshInstance3D.new()
	var cap := CapsuleMesh.new()
	cap.radius = 0.35; cap.height = 1.0
	body.mesh = cap
	body.position.y = 0.5
	body.material_override = Castle.material(VISITOR_COLORS[visitor_index % VISITOR_COLORS.size()])
	bean.add_child(body)
	var head := MeshInstance3D.new()
	var sph := SphereMesh.new()
	sph.radius = 0.3; sph.height = 0.6
	head.mesh = sph
	head.position.y = 1.25
	head.material_override = Castle.material(Color("f2c7a0"))
	bean.add_child(head)
	if visitor.get("id", "") == "dragon":
		bean.scale = Vector3.ONE * 1.3
	add_child(bean)
	bean.position = VISITOR_POS + Vector3(2.5, 0, 0)
	create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).tween_property(bean, "position", VISITOR_POS, 0.7)


func _leave_visitor() -> void:
	if bean:
		create_tween().tween_property(bean, "position", VISITOR_POS + Vector3(3, 0, 0), 0.6)


# ---------------------------------------------------------------- the dotted outline

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


# ---------------------------------------------------------------- UI

const INK := Color("2a2420")
const PAPER := Color("fbf5ec")


func _say(text: String) -> void:
	bubble.visible = true
	bubble_name.text = "%s · %s" % [visitor.get("name", ""), visitor.get("role", "")]
	bubble_text.text = text


func _update_hud() -> void:
	hud.text = "Visitor %d / %d    ★ %d" % [visitor_index + 1, day.visitors.size(), total_stars]


func _button(text: String, action: Callable) -> void:
	main_button.text = text
	for c in main_button.pressed.get_connections():
		main_button.pressed.disconnect(c.callable)
	main_button.pressed.connect(action)
	main_button.visible = true


func _build_ui() -> void:
	ui = CanvasLayer.new()
	add_child(ui)

	hud = _label(28)
	hud.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	hud.offset_top = 18; hud.offset_bottom = 60
	ui.add_child(hud)

	bubble = _panel(PAPER, 32)
	bubble.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	bubble.offset_left = 28; bubble.offset_right = -28; bubble.offset_top = 66
	bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(bubble)
	var bv := VBoxContainer.new()
	bv.add_theme_constant_override("separation", 6)
	bubble.add_child(bv)
	bubble_name = _label(26); bubble_name.add_theme_color_override("font_color", Color("9f683b"))
	bv.add_child(bubble_name)
	bubble_text = _label(36); bubble_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bv.add_child(bubble_text)
	bars = VBoxContainer.new()
	bars.add_theme_constant_override("separation", 8)
	bv.add_child(bars)
	var row := HBoxContainer.new(); bars.add_child(row)
	var ml := _label(28); ml.text = "Match "; row.add_child(ml)
	match_bar = _bar(Color("959b68")); row.add_child(match_bar)
	match_label = _label(28); match_label.custom_minimum_size.x = 86; row.add_child(match_label)
	var row2 := HBoxContainer.new(); bars.add_child(row2)
	var wl := _label(28); wl.text = "Wobble"; row2.add_child(wl)
	wobble_bar = _bar(Color("b2675d")); row2.add_child(wobble_bar)
	var spacer := Control.new(); spacer.custom_minimum_size.x = 86; row2.add_child(spacer)

	big_text = _label(110)
	big_text.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	big_text.offset_left = -340; big_text.offset_right = 340; big_text.offset_top = -120; big_text.offset_bottom = 20
	big_text.add_theme_color_override("font_color", Color("f2b345"))
	big_text.add_theme_color_override("font_outline_color", INK)
	big_text.add_theme_constant_override("outline_size", 18)
	ui.add_child(big_text)

	glaze_row = HBoxContainer.new()
	glaze_row.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	glaze_row.offset_left = -330; glaze_row.offset_right = 330; glaze_row.offset_top = -330; glaze_row.offset_bottom = -230
	glaze_row.alignment = BoxContainer.ALIGNMENT_CENTER
	glaze_row.add_theme_constant_override("separation", 14)
	ui.add_child(glaze_row)
	for id in Visitors.GLAZES:
		var g := Button.new()
		g.custom_minimum_size = Vector2(96, 96)
		for st in ["normal", "hover", "pressed", "focus"]:
			var sb := StyleBoxFlat.new()
			sb.bg_color = Visitors.GLAZES[id].color
			sb.border_color = INK; sb.set_border_width_all(6 if st != "pressed" else 10)
			sb.set_corner_radius_all(48)
			g.add_theme_stylebox_override(st, sb)
		g.pressed.connect(_pick_glaze.bind(id))
		glaze_row.add_child(g)

	main_button = Button.new()
	main_button.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	main_button.offset_left = -250; main_button.offset_right = 250
	main_button.offset_top = -180; main_button.offset_bottom = -70
	main_button.add_theme_font_size_override("font_size", 40)
	for st in ["normal", "hover", "pressed", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("ad5c37") if st != "pressed" else Color("7e3f24")
		sb.border_color = INK; sb.set_border_width_all(6); sb.set_corner_radius_all(55)
		main_button.add_theme_stylebox_override(st, sb)
	for c in ["font_color", "font_pressed_color", "font_hover_color", "font_focus_color"]:
		main_button.add_theme_color_override(c, Color.WHITE)
	ui.add_child(main_button)

	title_panel = _panel(Color(0.98, 0.96, 0.93, 0.92), 40)
	title_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	title_panel.offset_left = -310; title_panel.offset_right = 310; title_panel.offset_top = -80; title_panel.offset_bottom = 360
	title_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(title_panel)
	var tv := VBoxContainer.new(); tv.alignment = BoxContainer.ALIGNMENT_CENTER
	tv.add_theme_constant_override("separation", 22)
	title_panel.add_child(tv)
	var tn := _label(84); tn.text = "Kiln & Keep"; tv.add_child(tn)
	title_intro = _label(32); title_intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; tv.add_child(title_intro)
	var tap := _label(40); tap.text = "TAP TO OPEN THE WORKSHOP"; tap.add_theme_color_override("font_color", Color("ad5c37")); tv.add_child(tap)

	end_panel = _panel(Color(0.98, 0.96, 0.93, 0.94), 40)
	end_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	end_panel.offset_left = -320; end_panel.offset_right = 320; end_panel.offset_top = -560; end_panel.offset_bottom = -60
	ui.add_child(end_panel)
	var ev := VBoxContainer.new(); ev.alignment = BoxContainer.ALIGNMENT_CENTER
	ev.add_theme_constant_override("separation", 24)
	end_panel.add_child(ev)
	var et := _label(56); et.text = "Your castle"; ev.add_child(et)
	end_text = _label(34); end_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; ev.add_child(end_text)
	var again := Button.new(); again.text = "PLAY AGAIN"
	again.custom_minimum_size = Vector2(0, 100)
	again.add_theme_font_size_override("font_size", 40)
	again.pressed.connect(func(): get_tree().reload_current_scene())
	ev.add_child(again)
	end_panel.visible = false
	bubble.visible = false
	main_button.visible = false
	glaze_row.visible = false
	big_text.visible = false


func _panel(color: Color, radius: int) -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = color; sb.border_color = INK
	sb.set_border_width_all(6); sb.set_corner_radius_all(radius)
	sb.content_margin_left = 28; sb.content_margin_right = 28
	sb.content_margin_top = 20; sb.content_margin_bottom = 20
	p.add_theme_stylebox_override("panel", sb)
	return p


func _label(size: int) -> Label:
	var l := Label.new()
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", INK)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _bar(color: Color) -> ProgressBar:
	var b := ProgressBar.new()
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.custom_minimum_size.y = 34
	b.show_percentage = false
	var bg := StyleBoxFlat.new(); bg.bg_color = Color("eadccb"); bg.set_corner_radius_all(17)
	var fg := StyleBoxFlat.new(); fg.bg_color = color; fg.set_corner_radius_all(17)
	b.add_theme_stylebox_override("background", bg)
	b.add_theme_stylebox_override("fill", fg)
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return b
