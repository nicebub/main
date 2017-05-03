import SGLMath
import Foundation
import OpenGL

/*let VStride = MemoryLayout<Vertex>.stride
let fStride = MemoryLayout<GLfloat>.stride
let uiStride = MemoryLayout<GLuint>.stride
let pStride = MemoryLayout<vec3>.stride*/

class LightModel {
	var meshes: [LightMesh]
	var directory: String

	init( _  inModel: Model){
        meshes = []
		directory = inModel.directory
        copyModel(inModel: inModel)

	}

	public func draw( _ shader: Shader){
		for mesh in meshes {
			mesh.draw(shader: shader)
		}
	}

	private func copyModel(inModel: Model) {
		for i in 0...inModel.meshes.count - 1 {
			let vertices = inModel.meshes[i].vertices
			let indices = inModel.meshes[i].indices
			let textures = inModel.meshes[i].textures
			let VBO: GLuint = inModel.meshes[i].VBO
			let EBO: GLuint = inModel.meshes[i].EBO
			meshes.append(LightMesh(vertices, indices, textures, VBO, EBO))

		}

	}

}
