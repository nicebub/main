import Foundation
import OpenGL
//import CGLFW3

public class Shader {
	public private(set) var program:GLuint = 0

	public func getProgram() -> GLuint {
		return program
	}
	public init(vertex:String, fragment:String)
	{
		let vertexID = glCreateShader(GLenum(GL_VERTEX_SHADER))
		defer{ glDeleteShader(vertexID) }
		if let errorMessage = Shader.compileShader(shader: vertexID, source: vertex){
			fatalError(errorMessage)
		}
		let fragmentID = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
		defer{ glDeleteShader(fragmentID) }
		if let errorMessage = Shader.compileShader(shader: fragmentID, source: fragment){
			fatalError(errorMessage)
		}
		self.program = glCreateProgram()
		if let errorMessage = Shader.linkProgram(program: program, vertex: vertexID, fragment: fragmentID){
			fatalError(errorMessage)
		}
	}

	public convenience init(vertexFile:String, fragmentFile:String)
	{
		do {
			let vertexData = try NSData(contentsOfFile: vertexFile,
			 options: [.uncached, .alwaysMapped]) as Data
			let fragmentData = try NSData(contentsOfFile: fragmentFile,
			 options: [.uncached, .alwaysMapped]) as Data
				 let vertexString = String(data: vertexData, encoding: String.Encoding.utf8)
				 let fragmentString = String(data: fragmentData, encoding: String.Encoding.utf8)
				 self.init(vertex: String(vertexString!), fragment: String(fragmentString!))
		}
		catch let error as NSError {
			fatalError(error.localizedFailureReason!)
		}
	}

	deinit
	{
		glDeleteProgram(program)

	}

	public func use()
	{
		glUseProgram(program)
	}

	private static func compileShader(shader: GLuint, source: String) -> String?
	{
		var vertexShaderSourcePointer = (source as NSString).utf8String
		glShaderSource(shader, GLsizei(1), &vertexShaderSourcePointer, nil)
		glCompileShader(shader)
		var success: GLint = 0
		glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &success)
		guard success == GL_TRUE else
		{
			var logSize:GLint = 0
			glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &logSize)
			if logSize == 0 { return "" }
			var infoLog = [GLchar](repeating:0, count: Int(logSize))
			glGetShaderInfoLog(shader, logSize, nil, &infoLog)
			return String(cString:infoLog)
		}
		return nil
	}
	private static func linkProgram(program: GLuint, vertex: GLuint, fragment: GLuint) -> String?
	{
		glAttachShader(program, vertex)
		glAttachShader(program, fragment)
		glLinkProgram(program)

		var success: GLint = 0
		glGetProgramiv(program, GLenum(GL_LINK_STATUS), &success)
		guard success == GL_TRUE else
		{
			var logSize:GLint = 0
			glGetProgramiv(program, GLenum(GL_INFO_LOG_LENGTH), &logSize)
			if logSize == 0 { return "" }
			var infoLog = [GLchar](repeating:0, count: Int(logSize))
			glGetProgramInfoLog(program, logSize, nil, &infoLog)
			return String(cString:infoLog)
		}
		/*
		glGetProgramiv(program, GLenum(GL_LINK_STATUS), &success)
		guard success == GL_TRUE else
		{
			var logSize:GLint = 0
			glGetProgramiv(program, GLenum(GL_INFO_LOG_LENGTH), &logSize)
			if logSize == 0 { return "" }
			var infoLog = [GLchar](repeating:0, count: Int(logSize))
			glGetProgramInfoLog(program, logSize, nil, &infoLog)
			return String(cString:infoLog)
		}
         */
		return nil

	}
}
