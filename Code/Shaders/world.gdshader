shader_type canvas_item;

uniform vec2 size;

uniform float scale = 0.9;

uniform vec2 pixels = vec2(64.0, 64.0); // Amount of pixels from top to bottom


// Temp:

uniform vec2 resolution = vec2(1280.0, 720.0);
uniform vec3 line_color: source_color = vec3(0.2, 0.3, 0.5);
//uniform float zoom: hint_range(1.0, 50.0, 0.1) = 20.0;
uniform float thickness: hint_range(0.1, 10.0, 0.1) = 2.0;
uniform float brightness: hint_range(0.1, 4.0, 0.1) = 2.0;

float draw_grid(vec2 uv) {
	vec2 grid_uv = cos(uv * TAU);
	return max(grid_uv.x, grid_uv.y);
}

vec2 rotate(vec2 uv, float angle) {
	return uv * mat2(vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
}
//

float circle(in vec2 uv, float radius)
{
	vec2 dist = uv-vec2(0.5);
	return 1.0 - step(radius, dot(dist, dist)*4.0);
}

float smooth_circle(in vec2 uv, float radius, float smoothness)
{
	vec2 dist = uv-vec2(0.5);
	return 1.0 - smoothstep(radius-smoothness, radius+smoothness*2.0, dot(dist, dist)*4.0);
}

void fragment() 
{
	vec2 uv = UV;
	uv -= 0.5;
	uv.x *= size.x/size.y;
	uv += 0.5;
	vec2 uv_pixel = floor(uv*pixels)/pixels;
	vec2 pixel_size = vec2(1.0)/pixels;
	uv_pixel = uv_pixel + 0.5*pixel_size;
	
	//float scale_2 = scale * exp(-0.2 * TIME);
	
	vec3 circle1 = vec3(circle(uv_pixel, scale));
	vec3 circle_outline_color = 0.5 + 0.5 * cos(TIME/10.0+vec3(0.0,2.0,4.0));
	float smoothness = scale*0.25;//(0.25+scale-scale_2);
	vec3 circle2 = vec3(smooth_circle(uv_pixel, scale+smoothness, smoothness))*0.5*circle_outline_color;//vec3(0.0, 0.0, 1.0);
	
	vec3 color = circle1+circle2;
	
	
	//uv += vec2(sin(TIME) * 0.4, cos(TIME) * 0.6);
	//uv = rotate(uv, TIME * 0.1);
	float zoom = 64.0;
	float line_thickness = zoom * thickness / resolution.y;
	vec3 color2 = mix(color,smoothstep(1.0 - line_thickness, 1.0, draw_grid(uv * zoom)) * line_color, 0.5);
	
	COLOR = vec4(color2, 1.0);
}