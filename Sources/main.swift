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
var pCamera: Camera =  Camera(posX: 0.0, posY: 0.0, posZ: 3.0, upX: 0.0, upY: 1.0, upZ: 0.0, inYaw: yaw, inPitch: pitch, cameraFront)
var movementDisabled = false
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
//let lightFragmentFile = "/Users/scott/Projects/main/Sources/light.frag"
let ourShader = Shader(vertexFile: inVertexFile, fragmentFile: inFragmentFile)
//    let lightShader = Shader(vertexFile: inVertexFile, fragmentFile: lightFragmentFile)
/*let cubePositions:[vec3] = [
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
]*/

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

 let inModel = "/Users/scott/Projects/main/meshes/nanosuit/nanosuit.obj"
 let ourModel: Model = Model(path: inModel)

while (glfwWindowShouldClose(window) == GL_FALSE ){
	let currentFrame = GLfloat(glfwGetTime())
	deltaTime = currentFrame - lastFrame
	lastFrame = currentFrame
    // Poll for events
    glfwPollEvents()
    doMovement(window: window)

	//Use light blue/green to clear the screen
glClearColor(0.2, 0.3, 0.3, 1.0)
  // Clear the screen (window background)
  glClear(GLenum(GL_COLOR_BUFFER_BIT) | GLenum(GL_DEPTH_BUFFER_BIT))

  ourShader.use()
  var view = pCamera.getViewMatrix()

  let aspectRatio =  GLfloat(WIDTH) / GLfloat(HEIGHT)
  var projection = SGLMath.perspective(radians(pCamera.zoom!), aspectRatio, 0.1, 100.0)
  let viewLoc = glGetUniformLocation(ourShader.getProgram(), "view")
  withUnsafePointer(to: &view, {
	  $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { viewP in
	  	glUniformMatrix4fv(viewLoc, 1, GLboolean(GL_FALSE), viewP)}
  })
  let projectionLoc = glGetUniformLocation(ourShader.getProgram(), "projection")
  withUnsafePointer(to: &projection, {
	  $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { projectionP in
	  	glUniformMatrix4fv(projectionLoc, 1, GLboolean(GL_FALSE), projectionP)}
  })

  //used to have this last iteration
//  glBindVertexArray(VAO)


  let modelLoc = glGetUniformLocation(ourShader.getProgram(), "model")
    var model = mat4()
//    model = SGLMath.translate(model, cubePosition)
    model = SGLMath.translate(model, vec3(0.0, -1.75, 0.0))
	model = SGLMath.scale(model, vec3(0.2, 0.2, 0.2))
    withUnsafePointer(to: &model, {
  	  $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { modelP in
  	  	glUniformMatrix4fv(modelLoc, 1, GLboolean(GL_FALSE), modelP)}
    })
	ourModel.draw(ourShader)

/*    let lightColorLoc = glGetUniformLocation(ourShader.getProgram(), "lightColor")
    var light = mat4()
    light = SGLMath.translate(light, vec3(-1.75, -1.75, 0.0))
    light = SGLMath.scale(light, vec3(0.5, 0.5, 0.5))
    withUnsafePointer(to: &light, {
        $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { lightP in
            glUniformMatrix4fv(lightColorLoc, 1, GLboolean(GL_FALSE), lightP)}
    })
*/


  // ourLight.draw(lightShader)
  // Swap front and back buffers for the current window
  glfwSwapBuffers(window)

}

//Destroy the window and its context
glfwDestroyWindow(window)
}
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
	}
func scrollCallback(window: OpaquePointer?, xoffset: Double, yoffset: Double)
{
    if(!movementDisabled){
	pCamera.processMouseScroll(yoffset: GLfloat(yoffset))
    }
}
func doMovement(window: OpaquePointer?)
{
	if(!movementDisabled){
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
	if(keys[Int(GLFW_KEY_TAB)]){

        if(!keys[Int(GLFW_KEY_LEFT_SHIFT)]){
			glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_NORMAL)
			movementDisabled = true
        }
        else {
			glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED)
			movementDisabled = false
			firstMouse = true
        }
	}

}

main()
