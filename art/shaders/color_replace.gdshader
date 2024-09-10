shader_type canvas_item;

uniform vec4 foreground_color: source_color;
global uniform vec4 background_color;

void fragment() {
	const vec4 WHITE = vec4(1, 1, 1, 1);
	vec4 sprite_color = texture(TEXTURE, UV);
	vec4 final_color = sprite_color == WHITE ? foreground_color : background_color;
	COLOR = vec4(final_color.rgb, sprite_color.a);
}
