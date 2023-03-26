#version 450

#pragma parameter RADIUS "Radius:" 0.0 0.0 2.5 0.01

layout(push_constant) uniform Push{
	vec4 SourceSize;
	vec4 OriginalSize;
	vec4 OutputSize;
	uint FrameCount;
	float RADIUS;
} params;

layout(std140, set = 0, binding = 0) uniform UBO{
	mat4 MVP;
} global;

#pragma stage vertex
layout(location = 0) in vec4 Position;
layout(location = 1) in vec2 TexCoord;
layout(location = 0) out vec2 vTexCoord;

void main(){
	gl_Position = global.MVP * Position;
	vTexCoord = TexCoord;
}

#pragma stage fragment
layout(location = 0) in vec2 vTexCoord;
layout(location = 0) out vec4 FragColor;
layout(set = 0, binding = 2) uniform sampler2D Source;
layout(set = 0, binding = 3) uniform sampler2D lob1_pass;
layout(set = 0, binding = 4) uniform sampler2D refpass;

void main(){
	vec3 orig = texture(refpass, vTexCoord).rgb;
	vec3 lob1 = texture(lob1_pass, vTexCoord).rgb;
	vec3 lob2 = texture(Source, vTexCoord - 0.5 * params.SourceSize.zw).rgb;
	vec3 ret;
	if(params.RADIUS <= 1.0){ ret = mix(orig, lob1, params.RADIUS); }
	else if(params.RADIUS <= 2.0){ ret = mix(lob1, lob2, params.RADIUS - 1.0); }
	else {ret = lob2 + (lob2 - lob1) * (params.RADIUS - 2.0);}
	
	FragColor = vec4(ret, 1.0);
}
