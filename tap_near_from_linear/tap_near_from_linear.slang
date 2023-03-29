#version 450

#pragma parameter NEAR "Near:" 0.0 0.0 1.0 1.0

layout(push_constant) uniform Push
{
	vec4 SourceSize;
	vec4 OriginalSize;
	vec4 OutputSize;
	uint FrameCount;
	float NEAR;
} params;

layout(std140, set = 0, binding = 0) uniform UBO
{
	mat4 MVP;
} global;

#pragma stage vertex
layout(location = 0) in vec4 Position;
layout(location = 1) in vec2 TexCoord;
layout(location = 0) out vec2 vTexCoord;

void main()
{
   gl_Position = global.MVP * Position;
   vTexCoord = TexCoord;
}

#pragma stage fragment
layout(location = 0) in vec2 vTexCoord;
layout(location = 0) out vec4 FragColor;
layout(set = 0, binding = 2) uniform sampler2D Source;

void main(){
	vec3 tap;
	if(params.NEAR < 0.5){
		tap = texture(Source, vTexCoord).rgb;
	}else{
		vec2 pos = vTexCoord * params.SourceSize.xy;
		vec2 frac = fract(pos);
		vec2 dpos = pos - frac;
		vec2 center = dpos + 0.5;
		vec2 new_uv = center * params.SourceSize.zw;
		tap = texture(Source, new_uv).rgb;
	}
	FragColor = vec4(tap, 1.0);
}
