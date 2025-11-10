shader_type canvas_item;

uniform vec2 size;

uniform float scale = 0.9;
	
uniform float pixels = 64.0;
uniform vec3 line_color: source_color = vec3(0.2, 0.3, 0.5);
uniform float thickness: hint_range(0.1, 10.0, 0.1) = 2.0;

float draw_grid(vec2 uv)
{
	vec2 grid_uv = cos(uv * TAU);
	return max(grid_uv.x, grid_uv.y);
}

void fragment() 
{
	vec2 uv = UV;
	uv -= 0.5;
	uv.x *= size.x/size.y;
	uv += 0.5;

	float zoom = sin(TIME*0.2)*16.0+(3.0*pixels)/4.0;
	float line_thickness = zoom * thickness / size.y;

	vec2 dist = uv-vec2(0.5);
	float fade_start = scale;
	float fade = smoothstep(fade_start*0.25, 1.75, dot(dist, dist));
	vec3 grid = (smoothstep(1.0 - line_thickness, 1.0, draw_grid(0.5+(uv-0.5) * zoom)) * line_color)*0.5*(1.0-fade);
	
	vec3 color = grid;
	
	COLOR = vec4(color, 1.0);
}