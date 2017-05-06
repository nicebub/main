#version 330 core

layout (location = 0) in vec3 position;
layout (location = 1) in vec3 normal;
layout (location = 2) in vec2 texCoord;

struct Material {
	vec3 ambient;
	vec3 diffuse;
	vec3 specular;
	float shininess;
};

struct Light {
	vec3 position;
	vec3 ambient;
	vec3 diffuse;
	vec3 specular;
};

out vec2 TexCoord;
out vec3 FragPos;
out vec3 Normal;
//out vec3 lightPosition;
out vec3 lightingColor;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform vec3 LightPosition;
uniform vec3 cameraPosition;
uniform vec3 lightColor;
uniform float ambientStrength;
uniform float specularStrength;
uniform float diff;
uniform float shininess;
uniform mat3 transInv;
uniform Material material;
uniform Light light;

void main(){
	gl_Position = projection * view * model * vec4(position, 1.0f);

	vec3 Position = vec3(model * vec4(position, 1.0f));
	Normal = transInv * normal;
//	Normal = mat3(transpose(inverse(model))) * normal;

	vec3 ambient = material.ambient * light.ambient;

	vec3 norm = normalize(Normal);
	vec3 lightDir = normalize(LightPosition - Position);
	float diff = max(dot(norm, lightDir), 0.0);
	vec3 diffuse = light.diffuse * (diff * material.diffuse);

	vec3 cameraDir = normalize(cameraPosition - Position);
	vec3 reflectDir = reflect(-lightDir, norm);
	float spec = pow(max(dot(cameraDir, reflectDir), 0.0), material.shininess);
	vec3 specular = material.specular * spec * light.specular;

//	FragPos = vec3(view * model * vec4(position, 1.0f));
	TexCoord = texCoord;
	//lightPosition = vec3(view * vec4(LightPosition, 1.0));
	lightingColor = ambient + diffuse + specular;
}
