import Foundation
import SGLImage
import SGLMath
#if os(OSX)
import OpenGL
#endif

#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

let WIDTH:GLsizei = 800, HEIGHT:GLsizei = 600
var deltaTime = GLfloat(0.0)  // Time between current frame and last frame
var lastFrame = GLfloat(0.0)  // Time of last frame
var cameraFront = vec3(0.0, 0.0, -1.0)
var keys = [Bool](repeating: false, count: Int(GLFW_KEY_LAST)+1 )
var yaw = GLfloat(-90.0)
var pitch = GLfloat(0.0)
var lastX = GLfloat(WIDTH) / 2
var lastY = GLfloat(HEIGHT) / 2
var firstMouse = true
var lightsOff = false
var pCamera: Camera =  Camera(posX: 0.0, posY: 0.0, posZ: 3.0, upX: 0.0, upY: 1.0, upZ: 0.0, inYaw: yaw, inPitch: pitch, cameraFront)
var movementDisabled = false
var ambientStrength = vec3(1.0, 0.5, 0.31)
var specularStrength = vec3(0.5, 0.5, 0.5)
var diffuseStrength = vec3(1.0, 0.5, 0.31)
var shininess = 32
var diff = 0.0
var backgroundColor = vec3(0.0, 0.0, 0.0)
var ourShaderName = "phongShader"
var animationStopped = false
var clockTime: Double = glfwGetTime()
var lastClockTime: Double = clockTime
func main(){

//Initialize GLFW
if(glfwInit() == 0) {
  print("Failed to initialize GLFW! Peace!")
  return
}
defer { glfwTerminate() }

glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR,3)
glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR,3)
glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE)
glfwWindowHint(GLFW_RESIZABLE, GL_TRUE)
glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE)

//open a window and attach an OpenGL context to the window surface
guard let window = glfwCreateWindow(WIDTH, HEIGHT, "OpenGL test - Swift", nil, nil)
else {
  print("Failed to open a window! Peace!")
  return
}

//set the window context current
glfwMakeContextCurrent(window)

//Print the OpenGL version currently enabled on your machine
let version = String(cString: glGetString(GLenum(GL_VERSION)))
print(version)

glfwSetKeyCallback(window,keyCallback)
glfwSetCursorPosCallback(window,mouseCallback)
glViewport( 0, 0, WIDTH, HEIGHT)
glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED)
glfwSetScrollCallback(window, scrollCallback)
glEnable(GLenum(GL_DEPTH_TEST))

//var lastX  = GLfloat(WIDTH)  / 2.0
//var lastY  = GLfloat(HEIGHT) / 2.0

let fStride = MemoryLayout<GLfloat>.stride
let uiStride = MemoryLayout<GLuint>.stride

print("sizes: float: \(fStride)")
print("       UInt:  \(uiStride)")
//glDeleteShader(vertexShader)
//glDeleteShader(fragmentShader)
let inVertexFile = "/Users/scott/Projects/main/Sources/basic.vs"
let inFragmentFile = "/Users/scott/Projects/main/Sources/basic.frag"
let lightFragmentFile = "/Users/scott/Projects/main/Sources/light.frag"
let lightVertexFile = "/Users/scott/Projects/main/Sources/light.vs"
let phongVFile = "/Users/scott/Projects/main/Sources/phongVertex.vs"
let phongFFile = "/Users/scott/Projects/main/Sources/phongVertex.frag"
let phongShader = Shader(vertexFile: inVertexFile, fragmentFile: inFragmentFile)
let lightShader = Shader(vertexFile: lightVertexFile, fragmentFile: lightFragmentFile)
let phongVShader = Shader(vertexFile: phongVFile, fragmentFile: phongFFile)
var ourShader = phongShader
let _:[vec3] = [
  [ 0.0,  0.0,  0.0],
  [ 2.0,  5.0, -15.0],
  [-1.5, -2.2, -2.5],
  [-3.8, -2.0, -12.3],
  [ 2.4, -0.4, -3.5],
  [-1.7,  3.0, -7.5],
  [ 1.3, -2.0, -2.5],
  [ 1.5,  2.0, -2.5],
  [ 1.5,  0.2, -1.5],
  [-1.3,  1.0, -1.5]
]

/*
let vertices:[GLfloat] = [

	 0.5,  0.5, 0.0,   1.0, 0.0, 0.0,   1.0, 1.0,
	 0.5, -0.5, 0.0,   0.0, 1.0, 0.0,   1.0, 0.0,
	-0.5, -0.5, 0.0,   0.0, 0.0, 1.0,   0.0, 0.0,
	-0.5,  0.5, 0.0,   1.0, 1.0, 0.0,   0.0, 1.0
]*/
/*let indices:[GLuint] = [
	0, 1, 3,
	1, 2, 3
]*/

/*let texCoords: [GLfloat] = [
	0.0, 0.0,
	1.0, 0.0,
	0.5, 1.0
]*/
//let inModel = "/Users/scott/Projects/main/meshes/tank/t_34_obj.obj"
// let inModel = "/Users/scott/Projects/main/meshes/nanosuit/nanosuit.obj"
let inModel = "/Users/scott/Projects/main/meshes/cube.obj"
 let ourModel: Model = Model(path: inModel)

 var lightVAO: GLuint = 0
var VBO: GLuint = 0
//    var EBO: GLuint = 0


 glGenVertexArrays(1, &lightVAO)
    glGenBuffers(1, &VBO)
//    glGenBuffers(1, &EBO)
 glBindVertexArray(lightVAO)
 glBindBuffer(GLenum(GL_ARRAY_BUFFER), VBO)
    glBufferData(GLenum(GL_ARRAY_BUFFER), verticesNoNormals.count * fStride, verticesNoNormals, GLenum(GL_STATIC_DRAW))
  //  glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), EBO)
    //glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), uiStride * indices.count, indices, GLenum(GL_STATIC_DRAW))
 glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(5 * fStride), nil)
 glEnableVertexAttribArray(0)
 glBindVertexArray(0)

 var lightPosition = vec3(1.0, -1.75, 2.0)
 var lastLightPosition = vec3(0.0, 0.0, 0.0)
 var lightColor = vec3(2.0, 0.7, 1.3)
while (glfwWindowShouldClose(window) == GL_FALSE ){
	if(!animationStopped){
		clockTime = glfwGetTime()
	}
	else {
		clockTime = lastClockTime
	}
	switch ourShaderName {
	case "phongShader":
		ourShader = phongShader
		break
	case "phongVShader":
		ourShader = phongVShader
		break
	default:
		ourShader = phongShader
		break
	}
	let currentFrame = GLfloat(glfwGetTime())
	deltaTime = currentFrame - lastFrame
	lastFrame = currentFrame
    // Poll for events
    glfwPollEvents()
    doMovement(window: window)

	//Use light blue/green to clear the screen
glClearColor(backgroundColor.x, backgroundColor.y, backgroundColor.z, 1.0)
  // Clear the screen (window background)
  glClear(GLenum(GL_COLOR_BUFFER_BIT) | GLenum(GL_DEPTH_BUFFER_BIT))

  ourShader.use()
  if(!animationStopped){
	  lightPosition.x = GLfloat(sin(clockTime)) * 3.0
	  lightPosition.y = GLfloat(sin(clockTime))
	  lightPosition.z = GLfloat(cos(clockTime)) * 3.0
	  lastLightPosition = lightPosition
  }
  else {
	  lightPosition = lastLightPosition
  }
  lightColor.x = GLfloat(sin(clockTime * 2.0))
  lightColor.y = GLfloat(sin(clockTime * 0.7))
  lightColor.z = GLfloat(sin(clockTime * 1.3))

  var view = pCamera.getViewMatrix()
  let lightColorLoc = glGetUniformLocation(ourShader.getProgram(), "lightColor")
  let ambientLightLoc = glGetUniformLocation(ourShader.getProgram(), "light.ambient")
  let diffuseLightLoc = glGetUniformLocation(ourShader.getProgram(), "light.diffuse")
  let specularLightLoc = glGetUniformLocation(ourShader.getProgram(), "light.specular")
  let diffuseColor = lightColor * 0.5
  let ambientColor = diffuseColor * 0.2
  glUniform3f(ambientLightLoc, ambientColor.x, ambientColor.y, ambientColor.z)
  glUniform3f(diffuseLightLoc, diffuseColor.x, diffuseColor.y, diffuseColor.z)
  glUniform3f(specularLightLoc, 1.0, 1.0, 1.0)
  if(!lightsOff){
	  glUniform3f(lightColorLoc, lightColor.x, lightColor.y, lightColor.z)
  }
  else{
	  glUniform3f(lightColorLoc, 0.0, 0.0, 0.0)
  }
  let cameraPositionLoc = glGetUniformLocation(ourShader.getProgram(), "cameraPosition")
  glUniform3f(cameraPositionLoc, pCamera.position.x, pCamera.position.y, pCamera.position.z)

  let specularStrengthLoc = glGetUniformLocation(ourShader.getProgram(), "material.specular")
  withUnsafePointer(to: &specularStrength, {
	  $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { specularStrengthP in
	  	glUniform3f(specularStrengthLoc, specularStrength.x, specularStrength.y, specularStrength.z)}
  })

  let shininessLoc = glGetUniformLocation(ourShader.getProgram(), "material.shininess")
  glUniform1f(shininessLoc, GLfloat(shininess))

  let diffLoc = glGetUniformLocation(ourShader.getProgram(), "diff")
  glUniform1f(diffLoc, GLfloat(diff))

  let ambientStrengthLoc = glGetUniformLocation(ourShader.getProgram(), "material.ambient")
  withUnsafePointer(to: &ambientStrength, {
	  $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { ambientStrengthP in
	  	glUniform3f(ambientStrengthLoc, ambientStrength.x, ambientStrength.y, ambientStrength.z)}
  })
  let diffuseStrengthLoc = glGetUniformLocation(ourShader.getProgram(), "material.diffuse")
  withUnsafePointer(to: &diffuseStrength, {
	  $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { diffuseStrengthP in
		  glUniform3f(diffuseStrengthLoc, diffuseStrength.x, diffuseStrength.y, diffuseStrength.z)}
  })
	let lightPositionLoc = glGetUniformLocation(ourShader.getProgram(), "LightPosition")
	withUnsafePointer(to: &lightPosition, {
		$0.withMemoryRebound(to: GLfloat.self, capacity: 1) { lightPositionP in
			glUniform3f(lightPositionLoc, lightPosition.x, lightPosition.y, lightPosition.z)}
		})

  let aspectRatio =  GLfloat(WIDTH) / GLfloat(HEIGHT)
  var projection = SGLMath.perspective(radians(pCamera.zoom!), aspectRatio, 0.1, 100.0)
  var viewLoc = glGetUniformLocation(ourShader.getProgram(), "view")
  withUnsafePointer(to: &view, {
	  $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { viewP in
	  	glUniformMatrix4fv(viewLoc, 1, GLboolean(GL_FALSE), viewP)}
  })
  var projectionLoc = glGetUniformLocation(ourShader.getProgram(), "projection")
  withUnsafePointer(to: &projection, {
	  $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { projectionP in
	  	glUniformMatrix4fv(projectionLoc, 1, GLboolean(GL_FALSE), projectionP)}
  })


  //used to have this last iteration
//  glBindVertexArray(VAO)


  var modelLoc = glGetUniformLocation(ourShader.getProgram(), "model")
    var model = mat4()
//    model = SGLMath.translate(model, cubePosition)
    model = SGLMath.translate(model, vec3(0.0, -1.75, 0.0))
	model = SGLMath.scale(model, vec3(0.2, 0.2, 0.2))
    withUnsafePointer(to: &model, {
  	  $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { modelP in
  	  	glUniformMatrix4fv(modelLoc, 1, GLboolean(GL_FALSE), modelP)}
    })
	let transInvLoc = glGetUniformLocation(ourShader.getProgram(), "transInv")
	var transInv: mat3
	if(ourShaderName == "phongVShader"){
		transInv = mat3(transpose(inverse(model)))
	}
	else{
		transInv = mat3(transpose(inverse(view * model)))
	}
	withUnsafePointer(to: &transInv, {
		$0.withMemoryRebound(to: GLfloat.self, capacity: 1) { transInvP in
			glUniformMatrix3fv(transInvLoc, 1, GLboolean(GL_FALSE), transInvP)}
	})
	ourModel.draw(ourShader)

	lightShader.use()

	modelLoc = glGetUniformLocation(lightShader.getProgram(), "model")
	viewLoc = glGetUniformLocation(lightShader.getProgram(), "view")
	projectionLoc = glGetUniformLocation(lightShader.getProgram(), "projection")
    withUnsafePointer(to: &view, {
  	  $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { viewP in
  	  	glUniformMatrix4fv(viewLoc, 1, GLboolean(GL_FALSE), viewP)}
    })
    withUnsafePointer(to: &projection, {
  	  $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { projectionP in
  	  	glUniformMatrix4fv(projectionLoc, 1, GLboolean(GL_FALSE), projectionP)}
    })

    var light = mat4()
    light = SGLMath.translate(light, lightPosition)
    light = SGLMath.scale(light, vec3(0.2, 0.2, 0.2))
    withUnsafePointer(to: &light, {
        $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { lightP in
            glUniformMatrix4fv(modelLoc, 1, GLboolean(GL_FALSE), lightP)}
    })
	var lampColor = vec3()
	if(!lightsOff){
		lampColor = lightColor
	}
	else{
		lampColor = vec3(0.5, 0.5, 0.5)
	}
	let inColorLoc = glGetUniformLocation(lightShader.getProgram(), "inColor")
	withUnsafePointer(to: &lampColor, {
		$0.withMemoryRebound(to: GLfloat.self, capacity: 1) { lampColor in
			glUniform3f(inColorLoc, lampColor[0], lampColor[1], lampColor[2])
		}
	})
	glBindVertexArray(lightVAO)
	glDrawArrays(GLenum(GL_TRIANGLES), 0, 36)

	glBindVertexArray(0)


  // ourLight.draw(lightShader)
  // Swap front and back buffers for the current window
  glfwSwapBuffers(window)
}

//Destroy the window and its context
glfwDestroyWindow(window)
}
/*
func getCurrentShader() -> Shader {
	return ourShader
}

func setCurrentShader(inShader: Shader){
	ourShader = inShader
}*/
func mouseCallback(window: OpaquePointer?, xpos: Double, ypos: Double){
    if(!movementDisabled){
	if firstMouse {
		lastX = Float(xpos)
		lastY = Float(ypos)
		firstMouse = false
	}
	let xoffset = Float(xpos) - lastX
	let yoffset = lastY - Float(ypos)
	lastX = Float(xpos)
	lastY = Float(ypos)
	pCamera.processMouseMovement(xoffset: xoffset, yoffset: yoffset, constrainPitch: GLboolean(GL_TRUE))
    }
}
func keyCallback(window: OpaquePointer?, key: Int32, scancode: Int32, action: Int32, mode: Int32)
{
	if action == GLFW_PRESS {
	    keys[Int(key)] = true
	} else if action == GLFW_RELEASE {
	    keys[Int(key)] = false
	}
	if(keys[Int(GLFW_KEY_ESCAPE)]){
			glfwSetWindowShouldClose(window, GL_TRUE)
		}

		if(keys[Int(GLFW_KEY_W)]){
			glPolygonMode( GLenum(GL_FRONT_AND_BACK), GLenum(GL_LINE))
		}

		if(keys[Int(GLFW_KEY_F)]){
			glPolygonMode(GLenum(GL_FRONT_AND_BACK), GLenum(GL_FILL))
		}
		if(keys[Int(GLFW_KEY_LEFT_SHIFT)] || keys[Int(GLFW_KEY_RIGHT_SHIFT)]){
		}
		if keys[Int(GLFW_KEY_BACKSLASH)] {
			animationStopped = !animationStopped
			if (animationStopped) {
				lastClockTime = clockTime
			}
			else {
				glfwSetTime(lastClockTime)
			}
			sleep(1)
		}
		if(!lightsOff){
			if keys[Int(GLFW_KEY_1)] {
				ourShaderName = "phongShader"
			}
			if keys[Int(GLFW_KEY_2)] {
				ourShaderName = "phongVShader"
			}
			if keys[Int(GLFW_KEY_LEFT_BRACKET)] {
				ambientStrength.z -= 0.01
				backgroundColor.x -= 0.01
				backgroundColor.y -= 0.01
				backgroundColor.z -= 0.01
				if ambientStrength.z <= 0.0 {
					ambientStrength.z = 0.0
				}
				if backgroundColor.x <= 0.0 {
					backgroundColor.x = 0.0
				}
				if backgroundColor.y <= 0.0 {
					backgroundColor.y = 0.0
				}
				if backgroundColor.z <= 0.0 {
					backgroundColor.z = 0.0
				}
			}
			if keys[Int(GLFW_KEY_RIGHT_BRACKET)] {
				ambientStrength.z += 0.01
				backgroundColor.x += 0.01
				backgroundColor.y += 0.01
				backgroundColor.z += 0.01
				if ambientStrength.z >= 0.9 {
					ambientStrength.z = 0.9
				}
				if backgroundColor.x >= 0.9 {
					backgroundColor.x = 0.9
				}
				if backgroundColor.y >= 0.9 {
					backgroundColor.y = 0.9
				}
				if backgroundColor.z >= 0.9 {
					backgroundColor.z = 0.9
				}

			}
			if keys[Int(GLFW_KEY_COMMA)] {
				shininess -= 2
				if shininess <= 2 {
					shininess = 2
				}
			}
			if keys[Int(GLFW_KEY_PERIOD)] {
				shininess += 2
				if shininess >= 256 {
					shininess = 256
				}
			}
			if keys[Int(GLFW_KEY_SEMICOLON)] {
				specularStrength.x -= 0.01
				if specularStrength.x <= 0.0 {
					specularStrength.x = 0.0
				}
			}
			if keys[Int(GLFW_KEY_APOSTROPHE)] {
				specularStrength.x += 0.01
				if specularStrength.x >= 1.0 {
					specularStrength.x = 1.0
				}
			}
		}
		if(keys[Int(GLFW_KEY_TAB)]){

	        if(!movementDisabled){
				glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_NORMAL)
				movementDisabled = true
			//	animationStopped = true
	        }
	        else {
				glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED)
				movementDisabled = false
				firstMouse = true
		//		animationStopped = false
	        }
			sleep(UInt32(1.0))
		}

		if(!movementDisabled){
			if(keys[Int(GLFW_KEY_L)]){
				lightsOff = !lightsOff
				sleep(1)
			}
    }




}
func scrollCallback(window: OpaquePointer?, xoffset: Double, yoffset: Double)
{
    if(!movementDisabled){
	pCamera.processMouseScroll(yoffset: GLfloat(yoffset))
    }
}
func doMovement(window: OpaquePointer?)
{
    // Camera controls
    if keys[Int(GLFW_KEY_UP)] {
		pCamera.processKeyboard( direction: .forward, deltaTime: deltaTime)
    }
    if keys[Int(GLFW_KEY_DOWN)] {
		pCamera.processKeyboard( direction: .backward, deltaTime: deltaTime)
    }
    if keys[Int(GLFW_KEY_LEFT)] {
		pCamera.processKeyboard( direction: .left, deltaTime: deltaTime)
    }
    if keys[Int(GLFW_KEY_RIGHT)] {
		pCamera.processKeyboard( direction: .right, deltaTime: deltaTime)
    }
	if keys[Int(GLFW_KEY_EQUAL)] {
		pCamera.zoom = pCamera.zoom! - 1
		if pCamera.zoom! <= 1.0 {
			pCamera.zoom = 1.0
		}
	}
	if keys[Int(GLFW_KEY_MINUS)] {
		pCamera.zoom = pCamera.zoom! + 1
		if pCamera.zoom! >= 45.0 {
			pCamera.zoom = 45.0
		}

	}

}



main()
