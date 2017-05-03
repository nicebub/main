#version 330 core

//in vec3 outColor;
in vec2 TexCoord;

out vec4 color;

//uniform sampler2D ourTexture1;
//uniform sampler2D ourTexture2;

uniform vec3 lightColor;
uniform sampler2D texture_diffuse1;
//uniform sampler2D texture_specular1;

void main(){
	color = vec4(1.0);
//	color = vec4(lightColor * vec3(TexCoord, 0.0), 1.0);
}
