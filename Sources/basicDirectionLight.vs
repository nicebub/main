#version 330 core

layout (location = 0) in vec3 position;
layout (location = 1) in vec3 normal;
layout (location = 2) in vec2 texCoord;

out vec2 TexCoord;
out vec3 FragPos;
out vec3 Normal;
out vec4 lightPosition;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform vec4 LightPosition;
uniform mat3 transInv;

void main(){
	gl_Position = projection * view * model * vec4(position, 1.0f);
	FragPos = vec3(view * model * vec4(position, 1.0f));
	TexCoord = texCoord;
	Normal = transInv * normal;
//	Normal = mat3(transpose(inverse(view * model))) * normal;
	lightPosition = view * LightPosition;
}