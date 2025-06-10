shader_type canvas_item;
render_mode blend_mix;

uniform vec2 Speed = vec2(0.000000, -1.000000);
uniform sampler2D Texture2DParameter:repeat_enable;



void fragment() {
// Input:9
	float n_out9p0 = TIME;


// Vector2Parameter:12
	vec2 n_out12p0 = Speed;


// VectorOp:10
	vec2 n_out10p0 = vec2(n_out9p0) * n_out12p0;


// UVFunc:8
	vec2 n_in8p1 = vec2(1.00000, 1.00000);
	vec2 n_out8p0 = n_out10p0 * n_in8p1 + UV;


	vec4 n_out5p0;
// Texture2D:5
	n_out5p0 = texture(Texture2DParameter, n_out8p0);


// Output:0
	COLOR.rgb = vec3(n_out5p0.xyz);


}
