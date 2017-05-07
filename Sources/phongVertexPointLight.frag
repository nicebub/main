#version 330 core

in vec2 TexCoord;
in vec3 Normal;
in vec3 FragPos;
//in vec3 lightPosition;
in vec3 lightingColor;
out vec4 color;


uniform sampler2D texture_diffuse1;
//uniform vec3 lightPosition;
//uniform vec3 cameraPosition;

void main(){
	color = vec4(lightingColor, 1.0f);
//	color = vec4(lightingColor, 1.0f) * vec4(texture(texture_diffuse1,  TexCoord));
}
