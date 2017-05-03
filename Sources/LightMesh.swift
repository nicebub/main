
import Foundation
import OpenGL
import SGLMath

class LightMesh {
	public var vertices: [Vertex]
	public var indices: [GLuint]
	public var textures: [Texture]
    var VAO: GLuint = 0
    var VBO: GLuint = 0
    var EBO: GLuint = 0
    init(_ inVertices: [Vertex], _ inIndices: [GLuint], _ inTextures: [Texture], _ inVBO: GLuint, _ inEBO: GLuint){
		vertices = inVertices
		indices = inIndices
		textures = inTextures
		setupMesh(inVBO: inVBO, inEBO: inEBO)
	}

//	private var VAO: GLuint = 0
//	public var VBO: GLuint = 0
	public func draw(shader: Shader){
		glBindVertexArray(VAO)
		glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_INT), nil)
		glBindVertexArray(0)
	}


	private func setupMesh(inVBO: GLuint, inEBO: GLuint ){
		glGenVertexArrays(1, &VAO)
//		defer { glDeleteVertexArrays( 1, &VAO) }
//		glGenBuffers(1, &(super.VBO))
//		defer { glDeleteBuffers( 1, &VBO) }
//		glGenBuffers(1, &(inEBO))
//		defer { glDeleteBuffers( 1, &EBO) }
		glBindVertexArray(VAO)
		glBindBuffer(GLenum(GL_ARRAY_BUFFER), inVBO)
		glBufferData(GLenum(GL_ARRAY_BUFFER), VStride * vertices.count,
		vertices, GLenum(GL_STATIC_DRAW))
		glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), inEBO)
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


/*		glGenVertexArrays(1, &VAO)
		glBindVertexArray(VAO)
		glBindBuffer( GLenum(GL_ARRAY_BUFFER), inVBO)
		glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(3 * fStride), nil)
		glEnableVertexAttribArray(0)
		glBindVertexArray(0)*/
	}

}
