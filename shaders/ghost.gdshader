shader_type spatial;
// The dotted outline of the tower the customer wants. Always drawn on top.
render_mode unshaded, depth_test_disabled, cull_disabled;

uniform vec4 color : source_color = vec4(0.165, 0.141, 0.125, 0.75);

void fragment() {
	// UV.x runs along the line; cut it into dashes.
	if (fract(UV.x * 18.0) > 0.55) { discard; }
	ALBEDO = color.rgb;
	ALPHA = color.a;
}
