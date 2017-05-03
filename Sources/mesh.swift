//
//  mesh.swift
//  main
//
//  Created by Scott Lorberbaum on 4/28/17.
//
//

import Foundation
import OpenGL
import SGLMath

struct Vertex {
	var position: vec3 = vec3()
	var normal: vec3 = vec3()
	var texCoords: vec2 = vec2()
}

struct Texture {
	var id: GLuint = 0
	var type: String = String()
	var path: aiString = aiString()
}

let VStride = MemoryLayout<Vertex>.stride
let fStride = MemoryLayout<GLfloat>.stride
let uiStride = MemoryLayout<GLuint>.stride
let pStride = MemoryLayout<vec3>.stride

class Mesh {
	public var vertices: [Vertex]
	public var indices: [GLuint]
	public var textures: [Texture]
    var VAO: GLuint = 0
    var VBO: GLuint = 0
    var EBO: GLuint = 0
	init(inVertices: [Vertex], inIndices: [GLuint], inTextures: [Texture]){
		vertices = inVertices
		indices = inIndices
		textures = inTextures
		setupMesh()
	}
	public func getVBO() -> GLuint {
		return VBO
	}
	public func draw(shader: Shader){
		var diffuseNr: GLuint = 0
		var specularNr: GLuint = 0
        if( textures.count != 0){
		for i in 0...textures.count - 1 {
			glActiveTexture(GLenum(GL_TEXTURE0) + GLenum(i))
			var number: String
			let name: String = textures[i].type
			var count = 0
			if(name == "texture_diffuse"){
				 diffuseNr += 1
				 count += 1

			}
            else if(name == "texture_specular"){
				specularNr += 1
				count += 1
            }
			else {
				continue
			}
			_ = name.components(separatedBy: "[0-9]")
			number = String(count)
		    glUniform1i(glGetUniformLocation(shader.getProgram(), name + number), GLint(i))
			glBindTexture(GLenum(GL_TEXTURE_2D), textures[i].id)
		}
	}
		glBindVertexArray(VAO)
		glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_INT), nil)
		glBindVertexArray(0)
        if(textures.count != 0){
            for a in 0...textures.count - 1 {
                glActiveTexture(GLenum(GL_TEXTURE0) + GLenum(a))
                glBindTexture(GLenum(GL_TEXTURE_2D), 0)
            }
        }
	}
	private func setupMesh(){
		glGenVertexArrays(1, &VAO)
//		defer { glDeleteVertexArrays( 1, &VAO) }
		glGenBuffers(1, &VBO)
//		defer { glDeleteBuffers( 1, &VBO) }
		glGenBuffers(1, &EBO)
//		defer { glDeleteBuffers( 1, &EBO) }
		glBindVertexArray(VAO)
		glBindBuffer(GLenum(GL_ARRAY_BUFFER), VBO)
		glBufferData(GLenum(GL_ARRAY_BUFFER), VStride * vertices.count,
		vertices, GLenum(GL_STATIC_DRAW))
		glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), EBO)
		glBufferData( GLenum(GL_ELEMENT_ARRAY_BUFFER),
		uiStride * indices.count,
		indices, GLenum(GL_STATIC_DRAW))
		let pointer0offset = UnsafeRawPointer(bitPattern: 0)
		glEnableVertexAttribArray(0)
		glVertexAttribPointer( 0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(VStride), pointer0offset)
		let pointer1offset = UnsafeRawPointer(bitPattern: UInt((GLsizei(pStride))))
		glEnableVertexAttribArray(1)
		glVertexAttribPointer( 1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(VStride), pointer1offset)
		let pointer2offset = UnsafeRawPointer(bitPattern: UInt((GLsizei(pStride) * 2)))
		glEnableVertexAttribArray(2)
		glVertexAttribPointer( 2, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(VStride), pointer2offset)
		//only maybe this next line
	//	glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
		glBindVertexArray(0)
	}
}
