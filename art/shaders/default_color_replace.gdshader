shader_type canvas_item;
#include "color_replace.gdshaderinc"

global uniform vec4 default_foreground_color;
global uniform vec4 background_color;

void fragment() {
	COLOR = get_replaced_color(TEXTURE, UV, default_foreground_color, background_color);
}
