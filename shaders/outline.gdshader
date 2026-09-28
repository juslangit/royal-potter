shader_type spatial;
// Thick cartoon outline: the back of the model, pushed outward, in one flat colour.
render_mode unshaded, cull_front;

uniform vec4 color : source_color = vec4(0.165, 0.141, 0.125, 1.0);
uniform float thickness = 0.035;

void vertex() {
	VERTEX += NORMAL * thickness;
}

void fragment() {
	ALBEDO = color.rgb;
}
