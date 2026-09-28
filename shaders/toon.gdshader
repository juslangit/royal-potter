shader_type spatial;
// Toon shading: light falls in hard bands, not a smooth gradient.
// Used by every model in the game so they all look like one world.

uniform vec4 albedo : source_color = vec4(0.85, 0.51, 0.31, 1.0);
uniform float bands = 3.0;
uniform float shadow = 0.5;
uniform float wet = 0.0;          // 1 = wet clay: a moving highlight and throwing rings
uniform float gloss = 0.0;        // 1 = fired glaze: a hard white shine

varying vec3 local_pos;

void vertex() {
	local_pos = VERTEX;
}

void fragment() {
	vec3 col = albedo.rgb * COLOR.rgb;
	// Throwing rings: faint horizontal lines on wet clay.
	col *= 1.0 - wet * 0.06 * step(0.5, fract(local_pos.y * 22.0));
	ALBEDO = col;
	ROUGHNESS = 1.0;
	SPECULAR = 0.0;
}

void light() {
	float n = clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION;
	float stepped = floor(n * bands) / (bands - 1.0);
	float lit = mix(shadow, 1.0, clamp(stepped, 0.0, 1.0));
	DIFFUSE_LIGHT += LIGHT_COLOR / PI * lit;   // Godot multiplies by ALBEDO afterwards
	// Hard toon highlight for wet clay and glaze.
	vec3 h = normalize(LIGHT + VIEW);
	float spec = step(0.97, dot(NORMAL, h)) * max(wet * 0.25, gloss * 0.9);
	SPECULAR_LIGHT += LIGHT_COLOR / PI * spec;
}
