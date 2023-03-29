#version 450

#pragma format R32G32B32A32_UINT

layout(std140, set = 0, binding = 0) uniform UBO
{
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
layout(location = 0) out uvec4 FragColor;
layout(set = 0, binding = 2) uniform sampler2D Source;

void main(){
	vec4 tap0 = texture(Source, vTexCoord);
	vec4 tap1 = tap0.gbar;
	vec4 tap2 = tap1.gbar;
	vec4 tap3 = tap2.gbar;

	FragColor = uvec4(packUnorm4x8(tap0), packUnorm4x8(tap1), packUnorm4x8(tap2), packUnorm4x8(tap3));
}
