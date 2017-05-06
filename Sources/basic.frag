#version 330 core

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

in vec2 TexCoord;
in vec3 Normal;
in vec3 FragPos;
in vec3 lightPosition;
out vec4 color;


uniform vec3 lightColor;
uniform sampler2D texture_diffuse1;
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
	vec3 lightDir = normalize(lightPosition - FragPos);
	vec3 cameraDir = normalize(-FragPos);
	vec3 reflectDir = reflect(-lightDir, norm);
	float spec = pow(max(dot(cameraDir, reflectDir), 0.0), material.shininess);
	vec3 specular = material.specular * spec * light.specular;
	float diff = max(dot(norm, lightDir), 0.0);
	vec3 diffuse = light.diffuse * (diff * material.diffuse);
	vec3 ambient = material.ambient * light.ambient;
	color = vec4(ambient + diffuse + specular, 1.0f) * vec4(texture(texture_diffuse1,  TexCoord));
}
