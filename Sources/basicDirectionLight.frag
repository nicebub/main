#version 330 core

struct Material {
	sampler2D diffuse;
//	vec3 ambient;
//	vec3 diffuse;
	sampler2D specular;
	float shininess;
};

struct Light {
//	vec3 position;
	vec4 direction;
	vec3 ambient;
	vec3 diffuse;
	vec3 specular;
};

in vec2 TexCoord;
in vec3 Normal;
in vec3 FragPos;
in vec4 lightPosition;
out vec4 color;


uniform vec3 lightColor;
uniform sampler2D texture_diffuse1;
uniform sampler2D texture_specular1;
//uniform vec3 lightPosition;
uniform float ambientStrength;
uniform float specularStrength;
uniform vec3 cameraPosition;
uniform float shininess;
uniform float diff;
uniform Material material;
uniform Light light;
void main(){
	vec3 norm = normalize(Normal);
	vec4 lightDir = normalize(-light.direction);
	vec3 lightDir3 = vec3(lightDir.x, lightDir.y, lightDir.z);
	vec3 cameraDir = normalize(-FragPos);
	vec3 reflectDir = reflect(-lightDir3, norm);
	float spec = pow(max(dot(cameraDir, reflectDir), 0.0), material.shininess);
	vec3 specular = vec3(texture(texture_specular1, TexCoord)) * spec * light.specular;
	float diff = max(dot(norm, lightDir3), 0.0);
	vec3 diffuse = light.diffuse * (diff * vec3(texture(texture_diffuse1, TexCoord)));
	vec3 ambient = vec3(texture(texture_diffuse1, TexCoord)) * light.ambient;
//	color = vec4(ambient + diffuse + specular, 1.0f) * vec4(texture(texture_diffuse1,  TexCoord));
	color = vec4(ambient + diffuse + specular, 1.0f);

}
