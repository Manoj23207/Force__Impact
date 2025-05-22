shader_type fog;

uniform sampler2D noise_tex;
uniform float noise_scale = 1;


void fog() {
	float noise = texture(noise_tex, WORLD_POSITION.xz*noise_scale).r;
	DENSITY = noise;
	DENSITY *= step(0.0, -SDF);
	ALBEDO = vec3(1.0);
	}