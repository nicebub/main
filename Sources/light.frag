#version 330 core

//in vec2 TexCoord;
out vec4 color;

uniform vec3 inColor;
//uniform sampler2D texture_diffuse1;

void main(){
	color = vec4(inColor, 1.0);
}
