#version 450

#pragma parameter FSTR_BIL_RADIUS "Bilateral Radius:" 2.0 0.0 2.5 0.01
#pragma parameter FSTR_BIL_EDGE_PROTECC "Bilateral Edge Protection:" 10.0 0.0 20.0 1.0

layout(push_constant) uniform Push{
	vec4 SourceSize;
	vec4 OriginalSize;
	vec4 OutputSize;
	uint FrameCount;
	float FSTR_BIL_RADIUS;
	float FSTR_BIL_EDGE_PROTECC;
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
layout(set = 0, binding = 4) uniform sampler2D bilrefpass;

// I stole this from scalefx
// Reference: http://www.compuphase.com/cmetric.htm
float dist(vec3 A, vec3 B){
	float r = 0.5 * (A.r + B.r);
	vec3 d = A - B;
	vec3 c = vec3(2 + r, 4, 3 - r);

	return sqrt(dot(c*d, d)) / 3;
}

vec3 get_blur(vec3 orig, vec3 lob1, vec3 lob2, float radius){
	vec3 ret;
	if(radius <= 1.0){ ret = mix(orig, lob1, radius); }
	else if(radius <= 2.0){ ret = mix(lob1, lob2, radius - 1.0); }
	else {ret = lob2 + (lob2 - lob1) * (radius - 2.0);}

	return ret;
}

void main(){
	vec3 orig = texture(bilrefpass, vTexCoord).rgb;
	vec3 lob1 = texture(lob1_pass, vTexCoord).rgb;
	vec3 lob2 = texture(Source, vTexCoord - 0.5 * params.SourceSize.zw).rgb;
	float edge = dist(orig, get_blur(orig, lob1, lob2, 2.0));
	edge = pow(edge, 1.0 / params.FSTR_BIL_EDGE_PROTECC);

	FragColor = vec4(get_blur(orig, lob1, lob2, abs(1.0 - edge) * params.FSTR_BIL_RADIUS), dot(lob2, vec3(0.2989, 0.5870, 0.1140)));
}
