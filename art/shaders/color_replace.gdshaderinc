vec4 get_replaced_color(sampler2D passed_texture, vec2 passed_uv, vec4 foreground_color, vec4 background_color) {
	const vec4 WHITE = vec4(1, 1, 1, 1);
	vec4 sprite_color = texture(passed_texture, passed_uv);
	vec4 final_color = sprite_color == WHITE ? foreground_color : background_color;
	return vec4(final_color.rgb, sprite_color.a);
}