shader_type canvas_item;
#include "color_replace.gdshaderinc"

global uniform vec4 background_color;
global uniform vec4 default_foreground_color;
uniform vec4 outline_color : source_color = vec4(0);

void fragment() {
	vec4 replaced_color = get_replaced_color(TEXTURE, UV, default_foreground_color, background_color);
	
	float size_x = 1.0 / float(textureSize(TEXTURE, 0).x);
	float size_y = 1.0 / float(textureSize(TEXTURE, 0).y);
	vec4 sprite_color = texture(TEXTURE, UV);
	float alpha = -8.0 * sprite_color.a;
	alpha += texture(TEXTURE, UV + vec2(size_x, 0)).a;
	alpha += texture(TEXTURE, UV + vec2(-size_x, 0)).a;
	alpha += texture(TEXTURE, UV + vec2(0, size_y)).a;
	alpha += texture(TEXTURE, UV + vec2(0, -size_y)).a;
	alpha += texture(TEXTURE, UV + vec2(size_x, size_y)).a;
	alpha += texture(TEXTURE, UV + vec2(-size_x, -size_y)).a;
	alpha += texture(TEXTURE, UV + vec2(-size_x, size_y)).a;
	alpha += texture(TEXTURE, UV + vec2(size_x, -size_y)).a;
	vec4 final_color = mix(replaced_color, outline_color, clamp(alpha, 0.0, 1.0));
	
	COLOR = final_color;
}
