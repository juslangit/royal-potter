class_name Towers
## The towers customers can order. Each is a list of widths from bottom to top
## (1.0 = the widest part) and how tall the finished tower should stand.
## The widths are scaled so the tower uses exactly the clay on the wheel,
## so every wish can be made perfectly.
##
## Adding a tower is one line.

const LIST := [
	{"id": "watchtower", "name": "Watchtower", "height": 2.3,  "shape": [0.62, 0.58, 0.55, 0.53, 0.52, 0.52, 0.53, 0.56, 0.62, 0.66]},
	{"id": "round_keep", "name": "Round keep", "height": 0.9,  "shape": [1.0, 0.98, 0.96, 0.95, 0.95, 0.96, 0.98, 1.0]},
	{"id": "turret", "name": "Turret", "height": 1.7,      "shape": [0.55, 0.62, 0.66, 0.66, 0.66, 0.68, 0.8, 0.9, 0.9]},
	{"id": "onion_dome", "name": "Onion dome", "height": 1.8,  "shape": [0.5, 0.5, 0.55, 0.72, 0.86, 0.9, 0.82, 0.6, 0.38, 0.22]},
	{"id": "spire", "name": "Spire", "height": 2.4,       "shape": [0.95, 0.86, 0.74, 0.62, 0.5, 0.4, 0.3, 0.22, 0.16]},
	{"id": "gatehouse", "name": "Gatehouse", "height": 1.2,   "shape": [0.9, 0.9, 0.7, 0.66, 0.66, 0.7, 0.9, 0.95]},
]


## Width of a tower at a height given as 0..1 (1.0 = its widest part).
static func width_at(tower_shape: Array, t: float) -> float:
	var f := clampf(t, 0.0, 1.0) * (tower_shape.size() - 1)
	var i := int(floor(f))
	if i >= tower_shape.size() - 1:
		return tower_shape[tower_shape.size() - 1]
	return lerpf(tower_shape[i], tower_shape[i + 1], f - i)


## How much to scale a tower's widths so it uses exactly `clay_amount` of clay at
## its own height. Measured over `rings` rings, the same way the clay measures itself.
static func width_scale(tower: Dictionary, clay_amount: float, rings: int) -> float:
	var mean_sq := 0.0
	for i in rings:
		var w := width_at(tower.shape, float(i) / (rings - 1))
		mean_sq += w * w
	mean_sq /= rings
	return sqrt(clay_amount / (PI * mean_sq * tower.height))
