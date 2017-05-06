import SGLMath
import Foundation
struct Material {
	var ambient: vec3
	var diffuse: vec3
	var specular: vec3
	var shininess: Float
}

var emerald: Material = Material(ambient: vec3(0.0215,0.1745,0.0215),
                                 diffuse: vec3(0.07568,0.61424,0.07568),
                                 specular: vec3(0.633,0.727811,0.633),
                                 shininess: 0.6)
