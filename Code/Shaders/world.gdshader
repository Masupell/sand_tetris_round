shader_type canvas_item;

uniform vec2 size;

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
	vec2 uv_pixel = floor(uv*64.0)/64.0;
	
	vec3 circle1 = vec3(circle(uv_pixel, 0.9));
	vec3 circle_outline_color = 0.5 + 0.5 * cos(TIME/10.0+vec3(0.0,2.0,4.0));
	vec3 circle2 = vec3(smooth_circle(uv_pixel, 1.1, 0.2))*0.5*circle_outline_color;//vec3(0.0, 0.0, 1.0);
	
	vec3 color = circle1+circle2;
	
	COLOR = vec4(color, 1.0);
}