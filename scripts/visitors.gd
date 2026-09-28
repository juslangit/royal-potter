class_name Visitors
## The day's visitors, loaded from data/customers.json (written by Codex, approved by
## Luqman). Until that file exists, a plain placeholder day is used so the game runs.

const PATH := "res://data/customers.json"

const GLAZES := {
	"cream_crown":       {"name": "Cream Crown",       "color": Color("f0d6ae")},
	"sage_keep":         {"name": "Sage Keep",         "color": Color("959b68")},
	"sky_spire":         {"name": "Sky Spire",         "color": Color("7ba2da")},
	"honey_hall":        {"name": "Honey Hall",        "color": Color("f2b345")},
	"rose_turret":       {"name": "Rose Turret",       "color": Color("b2675d")},
	"terracotta_throne": {"name": "Terracotta Throne", "color": Color("ad5c37")},
}


## Returns {intro, day_start, visitors: [..7], ending: [..]}. The dragon is the last visitor.
static func load_day() -> Dictionary:
	var data: Variant = null
	if FileAccess.file_exists(PATH):
		data = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if typeof(data) != TYPE_DICTIONARY:
		data = _placeholder()
	var visitors: Array = data.customers.duplicate()
	var dragon: Dictionary = data.dragon
	dragon["id"] = "dragon"
	visitors.append(dragon)
	return {"intro": data.intro, "day_start": data.day_start, "visitors": visitors, "ending": data.ending}


## The tower a visitor wants, as {name, height, shape}. The dragon brings its own shape.
static func tower_for(visitor: Dictionary) -> Dictionary:
	if visitor.has("tower_shape"):
		return {"name": visitor.get("tower_name", "Dragon's roost"), "height": float(visitor.tower_height), "shape": visitor.tower_shape}
	for t in Towers.LIST:
		if t.id == visitor.tower:
			return t
	return Towers.LIST[0]


static func _placeholder() -> Dictionary:
	var towers := ["round_keep", "watchtower", "turret", "gatehouse", "onion_dome", "spire"]
	var glazes := GLAZES.keys()
	var list := []
	for i in towers.size():
		list.append({
			"id": "visitor_%d" % i, "name": "Visitor %d" % (i + 1), "role": "Placeholder",
			"tower": towers[i], "glaze_hint": glazes[i],
			"arrive": "Hello, potter!", "wish": "One tower, please.",
			"react": ["Oh… thank you.", "Nice!", "Lovely!", "Perfect!"],
			"sploosh": "Hehe, again?",
		})
	return {
		"intro": "Throw the towers. Build the castle.",
		"day_start": "The workshop is open!",
		"customers": list,
		"dragon": {
			"name": "Dragon", "role": "The Dragon", "arrive": "Hello?", "wish": "A tower for me?",
			"react": ["Oh.", "Nice.", "Lovely!", "PERFECT!"], "sploosh": "Hehe!",
			"tower_shape": [1.0, 0.9, 0.8, 0.75, 0.75, 0.8, 0.9, 1.0, 0.95, 0.9],
			"tower_height": 2.0, "glaze_hint": "rose_turret",
		},
		"ending": ["The castle is complete.", "The dragon moved in.", "Thanks for playing!"],
	}
