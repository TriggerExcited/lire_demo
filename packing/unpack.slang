#version 450

layout(push_constant) uniform Push{
	vec4 SourceSize;
	vec4 OriginalSize;
	vec4 OutputSize;
	uint FrameCount;
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
layout(set = 0, binding = 2) uniform usampler2D Source;

void main(){
	uvec4 packed = texture(Source, vTexCoord);
	vec4 tap0 = unpackUnorm4x8(packed.r);
	vec4 tap1 = unpackUnorm4x8(packed.g);
	vec4 tap2 = unpackUnorm4x8(packed.b);
	vec4 tap3 = unpackUnorm4x8(packed.a);

	FragColor = tap1;
}
