//import CGLFW3
//import SGLOpenGL
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

//import assimp

let WIDTH:GLsizei = 800, HEIGHT:GLsizei = 600
var deltaTime = GLfloat(0.0)  // Time between current frame and last frame
var lastFrame = GLfloat(0.0)  // Time of last frame
//var cameraPos = vec3(0.0, 0.0, 3.0)
var cameraFront = vec3(0.0, 0.0, -1.0)
//var cameraUp = vec3(0.0, 1.0, 0.0)
var keys = [Bool](repeating: false, count: Int(GLFW_KEY_LAST)+1 )
var yaw = GLfloat(-90.0)
var pitch = GLfloat(0.0)
var lastX = GLfloat(WIDTH) / 2
var lastY = GLfloat(HEIGHT) / 2
var firstMouse = true
//var fov = GLfloat(45.0)
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

var lastX  = GLfloat(WIDTH)  / 2.0
var lastY  = GLfloat(HEIGHT) / 2.0

let fStride = MemoryLayout<GLfloat>.stride
let uiStride = MemoryLayout<GLuint>.stride

print("sizes: float: \(fStride)")
print("       UInt:  \(uiStride)")
//glDeleteShader(vertexShader)
//glDeleteShader(fragmentShader)
var inVertexFile = "/Users/scott/Projects/main/Sources/basic.vs"
let inFragmentFile = "/Users/scott/Projects/main/Sources/basic.frag"
var lightFragmentFile = "/Users/scott/Projects/main/Sources/light.frag"
let ourShader = Shader(vertexFile: inVertexFile, fragmentFile: inFragmentFile)
    let lightShader = Shader(vertexFile: inVertexFile, fragmentFile: lightFragmentFile)
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

//let ourModel: Model = Model(path: "/Users/scott/Projects/main/meshes/wperson/groppi.obj")
//let ourModel: Model = Model(path: "/Users/scott/Projects/main/meshes/nanosuit/nanosuit.obj")
//let ourModel: Model = Model(path: "/Users/scott/Projects/main/meshes/tank/t_34_obj.obj")
let inModel = "/Users/scott/Projects/main/meshes/nanosuit/nanosuit.obj"
 let ourModel: Model = Model(path: inModel)
// let ourLight: LightModel = LightModel(ourModel)

// let ourModel: Model = Model(path: "/Users/scott/Downloads/Alice Murray/Alice Murray.obj")

 //print("ourModel's attributes Meshes then textures_loaded")
//print("Meshes", ourModel.meshes)
//for mesh in ourModel.meshes {
//	print("Mesh Vertices", mesh.vertices)
//	print("Mesh Indices", mesh.indices)
//	print("Mesh Textures", mesh.textures)
//}
//print("Textures_loaded", ourModel.textures_loaded)
/*var VAO:GLuint = 0
glGenVertexArrays(1, &VAO)
defer { glDeleteVertexArrays( 1, &VAO) }

var VBO:GLuint = 0
glGenBuffers( 1, &VBO)
defer { glDeleteBuffers( 1, &VBO) }

/*var EBO:GLuint = 0
glGenBuffers(1, &EBO)
defer { glDeleteBuffers( 1, &EBO) }*/


glBindVertexArray(VAO)
glBindBuffer(GLenum(GL_ARRAY_BUFFER), VBO)
//    let mushverticesPointer = UnsafeRawPointer(bitPattern: Int(mushroom.mushroomVertices))
glBufferData( GLenum(GL_ARRAY_BUFFER),
		fStride * vertices.count,
		vertices, GLenum(GL_STATIC_DRAW))

/*glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), EBO)
glBufferData( GLenum(GL_ELEMENT_ARRAY_BUFFER),
						uiStride * indices.count,
						indices, GLenum(GL_STATIC_DRAW))*/

let pointer0offset = UnsafeRawPointer(bitPattern: 0)
glVertexAttribPointer( 0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(fStride * 5), pointer0offset)
glEnableVertexAttribArray(0)

let pointer1offset = UnsafeRawPointer(bitPattern: UInt((GLsizei(fStride) * 3)))
glVertexAttribPointer( 1, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(fStride * 5), pointer1offset)
glEnableVertexAttribArray(1)

/*let pointer2offset = UnsafeRawPointer(bitPattern: UInt((GLsizei(fStride) * 6)))
glVertexAttribPointer( 2, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(fStride * 8), pointer2offset)
glEnableVertexAttribArray(2)*/

/*
    let pointer0offset = UnsafeRawPointer(bitPattern: 0)
    //let mushposPointer =  UnsafeRawPointer(mushroomPositions).assumingMemoryBound(to: GLfloat.self)
    glVertexAttribPointer( 0, 3,GLenum(GL_FLOAT),
            GLboolean(GL_FALSE),0,indices)
    glEnableVertexAttribArray(0)
*/

glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
glBindVertexArray(0)
*/
/*
SGLImageLoader.flipVertical = true


var texture:GLuint = 0
glGenTextures(1, &texture)
glBindTexture(GLenum(GL_TEXTURE_2D), texture)

glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_REPEAT)
glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_REPEAT)

glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)

let loader = SGLImageLoader(fromFile: "/Users/scott/Projects/main/Sources/container.png")
if( loader.error != nil) { fatalError(loader.error!) }

let image = SGLImageRGB<UInt8>(loader)
if( loader.error != nil) { fatalError(loader.error!) }

image.withUnsafeMutableBufferPointer() {
	glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGB,
		GLsizei(image.width),
		GLsizei(image.height),
		0, GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE),
		$0.baseAddress)
}
glGenerateMipmap(GLenum(GL_TEXTURE_2D) )
glBindTexture(GLenum(GL_TEXTURE_2D), 0)






var texture2:GLuint = 0
glGenTextures(1, &texture2)
glBindTexture(GLenum(GL_TEXTURE_2D), texture2)

glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_REPEAT)
glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_REPEAT)

glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)

let loader2 = SGLImageLoader(fromFile: "/Users/scott/Projects/main/Sources/awesomeface.png")
if( loader2.error != nil) { fatalError(loader2.error!) }

let image2 = SGLImageRGBA<UInt8>(loader2)
if( loader2.error != nil) { fatalError(loader2.error!) }

image2.withUnsafeMutableBufferPointer() {
	glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA,
		GLsizei(image2.width),
		GLsizei(image2.height),
		0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE),
		$0.baseAddress)
}
glGenerateMipmap(GLenum(GL_TEXTURE_2D) )
glBindTexture(GLenum(GL_TEXTURE_2D), 0)
*/
/*var vec = vec4(1.0, 0.0, 0.0, 1.0)
var trans = mat4()
trans = SGLMath.translate(trans, vec3(1.0,1.0,1.0))
vec = trans * vec
print(vec.xyz)  //Vector3<Float>(2.0, 1.0, 0.0)*/



while (glfwWindowShouldClose(window) == GL_FALSE ){
	let currentFrame = GLfloat(glfwGetTime())
	deltaTime = currentFrame - lastFrame
	lastFrame = currentFrame
    // Poll for events
    glfwPollEvents()
    doMovement(window: window)

	//Use red to clear the screen
//	glClearColor( 1, 0, 0, 1)
glClearColor(0.2, 0.3, 0.3, 1.0)
  // Clear the screen (window background)
  glClear(GLenum(GL_COLOR_BUFFER_BIT) | GLenum(GL_DEPTH_BUFFER_BIT))
  ourShader.use()
/*  glActiveTexture(GLenum(GL_TEXTURE0))
  glBindTexture(GLenum(GL_TEXTURE_2D), texture)
  glUniform1i(glGetUniformLocation(ourShader.getProgram(), "ourTexture1"), 0)
  glActiveTexture(GLenum(GL_TEXTURE1))
  glBindTexture(GLenum(GL_TEXTURE_2D), texture2)
  glUniform1i(glGetUniformLocation(ourShader.getProgram(), "ourTexture2"), 1)
  */
/*  var transform = mat4()
  transform = SGLMath.translate(transform, vec3(0.5, -0.5, 0.0))
  transform = SGLMath.rotate(transform, Float(glfwGetTime()), vec3(0.0,0.0,1.0))
  transform = SGLMath.scale(transform, vec3(0.5,0.5,0.5))
  let transformLoc = glGetUniformLocation(ourShader.getProgram(), "transform")
  withUnsafePointer(to: &transform, {
  	$0.withMemoryRebound(to: GLfloat.self, capacity: 1) { transformChar in
  	glUniformMatrix4fv(transformLoc, 1, GLboolean(GL_FALSE), transformChar)
  }
  })*/
//  var model = SGLMath.rotate(mat4(), GLfloat(glfwGetTime()), vec3(0.5,1.0,0.0))

/*let cameraTarget = vec3(0.0, 0.0, 0.0)
let cameraDirection = normalize(cameraPos - cameraTarget)
let up = vec3(0.0, 1.0, 0.0)
let cameraRight = normalize(cross(up, cameraDirection))
let radius = 10.0
let camX = Float(sin(glfwGetTime()) * radius)
let camZ = Float(cos(glfwGetTime()) * radius)*/
//var view = SGLMath.lookAt(cameraPos, cameraPos + cameraFront, cameraUp)
var view = pCamera.getViewMatrix()

//  var view = SGLMath.translate(mat4(), vec3(0.0,0.0,-3.0))
  let aspectRatio =  GLfloat(WIDTH) / GLfloat(HEIGHT)
//  var projection = SGLMath.perspective(radians(fov), aspectRatio, 0.1, 100.0)
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
  //let timeValue = glfwGetTime()
  //let greenValue = ( sin(timeValue) / 2 + 0.5)
  //let vertexColorLocation = glGetUniformLocation(ourShader.getProgram(), "vertexColor")
  //glUniform4f(vertexColorLocation, 0.0, Float(greenValue), 0.0, 1.0)


  //used to have this last iteration
//  glBindVertexArray(VAO)


  let modelLoc = glGetUniformLocation(ourShader.getProgram(), "model")
//  for (index, cubePosition) in cubePositions.enumerated() {
    var model = mat4()
//    model = SGLMath.translate(model, cubePosition)
    model = SGLMath.translate(model, vec3(0.0, -1.75, 0.0))
//	if( index % 3 != 0){
	model = SGLMath.scale(model, vec3(0.2, 0.2, 0.2))
 //   	model = SGLMath.rotate(model, Float(index), vec3(0.5, 1.0, 0.0))
//	}
//	else {
//		model = SGLMath.rotate(model, Float(glfwGetTime()), vec3(0.5, 1.0, 0.0))
//}

    withUnsafePointer(to: &model, {
  	  $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { modelP in
  	  	glUniformMatrix4fv(modelLoc, 1, GLboolean(GL_FALSE), modelP)}
    })


/*    let lightColorLoc = glGetUniformLocation(ourShader.getProgram(), "lightColor")
    var light = mat4()
    light = SGLMath.translate(light, vec3(-1.75, -1.75, 0.0))
    light = SGLMath.scale(light, vec3(0.5, 0.5, 0.5))
    withUnsafePointer(to: &light, {
        $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { lightP in
            glUniformMatrix4fv(lightColorLoc, 1, GLboolean(GL_FALSE), lightP)}
    })
*/
	ourModel.draw(ourShader)
 //   ourLight.draw(lightShader)
 //  glDrawArrays(GLenum(GL_TRIANGLES), 0, 36)
//  }

//  glDrawArrays(GLenum(GL_TRIANGLES), 0, 36)
//  glDrawElements(GLenum(GL_TRIANGLES), 6, GLenum(GL_UNSIGNED_INT), nil)


//    glDrawArrays(GLenum(GL_TRIANGLES), 0, Mushroom.mushroomVertices)
/*
var transform2 = mat4()
transform2 = SGLMath.translate(transform2, vec3(-0.5, 0.5, 0.0))
transform2 = SGLMath.rotate(transform2, radians(90.0), vec3(0.0,0.0,1.0))
let mySin = Float(sin(glfwGetTime()))
transform2 = SGLMath.scale(transform2, vec3(mySin,mySin,mySin))
    let transformLoc2 = glGetUniformLocation(ourShader.getProgram(), "transform")
    withUnsafePointer(to: &transform2, {
        $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { transformChar2 in
            glUniformMatrix4fv(transformLoc2, 1, GLboolean(GL_FALSE), transformChar2)
        }
    })
    glBindVertexArray(VAO)
glDrawElements(GLenum(GL_TRIANGLES), 6, GLenum(GL_UNSIGNED_INT), nil)*/
//    glBindVertexArray(0)

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
	/*
	let sensitivity = pCamera.MouseSensitivity
	let sensitivity = GLfloat(0.05)
	xoffset *= sensitivity
	yoffset *= sensitivity
	yaw += xoffset
	pitch += yoffset
	if (pitch > 89.0) {
	    pitch = 89.0
	}
	if (pitch < -89.0) {
	    pitch = -89.0
	}
	var front = vec3()
	front.x = cos(radians(yaw)) * cos(radians(pitch))
	front.y = sin(radians(pitch))
	front.z = sin(radians(yaw)) * cos(radians(pitch))
	cameraFront = normalize(front)*/
//	print("values are: xoffset | yoffset | lastX | lastY")
//	print("         \(xoffset) | \(yoffset) | \(lastX) | \(lastY)")
	pCamera.processMouseMovement(xoffset: xoffset, yoffset: yoffset, constrainPitch: GLboolean(GL_TRUE))
    }
}
func keyCallback(window: OpaquePointer?, key: Int32, scancode: Int32, action: Int32, mode: Int32)
{
//    print("this is the key value: ", key)
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
/*		if(key == GLFW_KEY_LEFT){
			cameraPos -= normalize(cross(cameraFront, cameraUp)) * cameraSpeed
		}
		if(key == GLFW_KEY_RIGHT){
			cameraPos += normalize(cross(cameraFront, cameraUp)) * cameraSpeed
		}
		if(key == GLFW_KEY_UP){
			cameraPos += cameraSpeed * cameraFront
		}
		if(key == GLFW_KEY_DOWN){
			cameraPos -= cameraSpeed * cameraFront
		}*/
}
func scrollCallback(window: OpaquePointer?, xoffset: Double, yoffset: Double)
{
    if(!movementDisabled){
	pCamera.processMouseScroll(yoffset: GLfloat(yoffset))
    }
/*    if (fov >= 1.0 && fov <= 45.0) {
        fov -= Float(yoffset)
    }
    if fov <= 1.0 {
        fov = 1.0
    }
    if fov >= 45.0 {
        fov = 45.0
    }*/
}
func doMovement(window: OpaquePointer?)
{
	if(!movementDisabled){
    // Camera controls
//    let cameraSpeed = Float(5.0) * deltaTime
    if keys[Int(GLFW_KEY_UP)] {
		pCamera.processKeyboard( direction: .forward, deltaTime: deltaTime)
//        cameraPos += cameraSpeed * cameraFront
//		print("the current movement speed is: \(pCamera.movementSpeed)")
//		pCamera.position += pCamera.movementSpeed! * pCamera.front
    }
    if keys[Int(GLFW_KEY_DOWN)] {
//        cameraPos -= cameraSpeed * cameraFront
		pCamera.processKeyboard( direction: .backward, deltaTime: deltaTime)
//		pCamera.position -= pCamera.movementSpeed! * pCamera.front
    }
    if keys[Int(GLFW_KEY_LEFT)] {
//        cameraPos -= normalize(cross(cameraFront, cameraUp)) * cameraSpeed
		pCamera.processKeyboard( direction: .left, deltaTime: deltaTime)
//		pCamera.position -= normalize(cross(pCamera.front, pCamera.up)) * pCamera.movementSpeed!
    }
    if keys[Int(GLFW_KEY_RIGHT)] {
		pCamera.processKeyboard( direction: .right, deltaTime: deltaTime)
//		pCamera.position += normalize(cross(pCamera.front, pCamera.up)) * pCamera.movementSpeed!
//        cameraPos += normalize(cross(cameraFront, cameraUp)) * cameraSpeed
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
