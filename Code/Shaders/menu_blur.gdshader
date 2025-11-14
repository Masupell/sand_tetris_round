shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;
uniform float blur_radius: hint_range(0.5, 5.0) = 1.6;
uniform vec4 tint: source_color = vec4(0.9, 0.9, 0.95, 0.16);
uniform float noise_strength: hint_range(0.0,0.05) = 0.02;
uniform float darkness: hint_range(0.0, 1.0, 0.1) = 0.3;

float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec3 blur(vec2 uv, vec2 texel, float radius)
{
    vec3 sum = vec3(0.0);
    float total = 0.0;
    for(float x=-radius; x<=radius; x++)
	{
        for(float y=-radius; y<=radius; y++)
		{
            float w = exp(-(x*x + y*y)/(2.0*radius*radius));
            sum += texture(SCREEN_TEXTURE, uv + vec2(x,y)*texel).rgb * w;
            total += w;
        }
    }
    return sum/total;
}

void fragment()
{
    vec2 texel = blur_radius / vec2(textureSize(SCREEN_TEXTURE,0));
    vec3 blurred = blur(SCREEN_UV, texel, blur_radius);

    float n = (rand(SCREEN_UV*1000.0)-0.5)*2.0 * noise_strength;
    vec3 noise = vec3(n);

    vec3 final_color = mix(blurred, tint.rgb, tint.a) + noise;
	final_color = mix(final_color, vec3(0,0,0), darkness);

    COLOR = vec4(final_color,1.0);
}