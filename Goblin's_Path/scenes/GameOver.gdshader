/*
	Glitch Effect Shader by Yui Kinomoto @arlez80

	MIT License
*/

shader_type canvas_item;

uniform float shake_power = 0.03;
uniform float shake_rate : hint_range(0.0, 1.0) = 0.2;
uniform float shake_speed = 5.0;
uniform float shake_block_size = 30.5;

float random(float seed) {
    return fract(543.2543 * sin(dot(vec2(seed, seed), vec2(3525.46, -54.3415))));
}

void fragment() {
    float enable_shift = float(
        random(trunc(TIME * shake_speed)) < shake_rate
    );

    vec2 fixed_uv = UV;
    fixed_uv.x += (
        random((trunc(UV.y * shake_block_size) / shake_block_size) + TIME) - 0.5
    ) * shake_power * enable_shift;

    // Just use distorted UV, no RGB splitting
    vec4 pixel_color = texture(TEXTURE, fixed_uv) * COLOR;
    COLOR = pixel_color;
}