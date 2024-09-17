shader_type canvas_item;
#include "color_replace.gdshaderinc"

uniform vec4 foreground_color: source_color;
global uniform vec4 background_color;

void fragment() {
	COLOR = get_replaced_color(TEXTURE, UV, foreground_color, background_color);
}
