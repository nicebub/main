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
var ambientStrength = emerald.ambient
var specularStrength = emerald.specular
var diffuseStrength = emerald.diffuse
//var shininess = emerald.shininess
var shininess = 16.0
var diff = 0.0
var backgroundColor = vec3(0.0, 0.0, 0.0)
var ourShaderName = "phongShader"
var animationStopped = false
var clockTime: Double = glfwGetTime()
var lastClockTime: Double = clockTime
var modelPosition = vec3(0.0, -1.75, 0.0)
var modelPosition2 = vec3(0.0, -1.75, -20.0)
var modelPosition3 = vec3(-1.0, -1.75, -5.0)
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
let inVertexFile = "/Users/scott/Projects/main/Sources/basicDirectionLight.vs"
let inFragmentFile = "/Users/scott/Projects/main/Sources/basicDirectionLight.frag"
let lightFragmentFile = "/Users/scott/Projects/main/Sources/light.frag"
let lightVertexFile = "/Users/scott/Projects/main/Sources/light.vs"
let phongVFile = "/Users/scott/Projects/main/Sources/phongVertex.vs"
let phongFFile = "/Users/scott/Projects/main/Sources/phongVertex.frag"
let inVertexPointFile = "/Users/scott/Projects/main/Sources/pointlight.vs"
let inFragmentPointFile = "/Users/scott/Projects/main/Sources/pointlight.frag"
let phongVPointVtexFile = "/Users/scott/Projects/main/Sources/phongVertexPointLight.vs"
let phongVPointFragFile = "/Users/scott/Projects/main/Sources/phongVertexPointLight.frag"
//let inVertexPointDebugFile = "/Users/scott/Projects/main/Sources/pointlightdebug.vs"
//let inFragmentPointDebugFile = "/Users/scott/Projects/main/Sources/pointlightdebug.frag"
//let inFragmentPointDebugFile2 = "/Users/scott/Projects/main/Sources/pointlightdebug2.frag"
let phongShader = Shader(vertexFile: inVertexFile, fragmentFile: inFragmentFile)
let lightShader = Shader(vertexFile: lightVertexFile, fragmentFile: lightFragmentFile)
let phongVShader = Shader(vertexFile: phongVFile, fragmentFile: phongFFile)
let phongShaderPoint = Shader(vertexFile: inVertexPointFile, fragmentFile: inFragmentPointFile)
let phongVShaderPoint = Shader(vertexFile: phongVPointVtexFile, fragmentFile: phongVPointFragFile)
//let phongShaderPointDebug = Shader(vertexFile: inVertexPointDebugFile, fragmentFile: inFragmentPointDebugFile)
//let phongShaderPointDebug2 = Shader(vertexFile: inVertexPointDebugFile, fragmentFile: inFragmentPointDebugFile2)
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
 let inModel = "/Users/scott/Projects/main/meshes/nanosuit/nanosuit.obj"
let dModel = "/Users/scott/Projects/main/meshes/cube2.obj"
 let ourModel: Model = Model(path: inModel)
// let debugModel: Model = Model(path: dModel)
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

 var lightPosition = vec4(0.0, -1.75, 0.0, 1.0)
 var lastLightPosition = vec4(0.0, 0.0, 0.0, 1.0)
 let lightColor = vec3(1.0, 1.0, 1.0)
 let lightDirection = vec4(-0.2, -0.2, -0.2, 0.0)
 let constantLoc = glGetUniformLocation(ourShader.getProgram(), "light.constant")
 glUniform1f(constantLoc, 1.0)
 glUniform1f(glGetUniformLocation(ourShader.getProgram(), "light.linear"), 0.22)
 glUniform1f(glGetUniformLocation(ourShader.getProgram(), "light.quadratic"), 0.09)

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
	case "phongVShaderPoint":
		ourShader = phongVShaderPoint
		break
		case "phongShaderPoint":
		ourShader = phongShaderPoint
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
//  lightColor.x = GLfloat(sin(clockTime * 2.0))
 // lightColor.y = GLfloat(sin(clockTime * 0.7))
  //lightColor.z = GLfloat(sin(clockTime * 1.3))

  var view = pCamera.getViewMatrix()
  var lightColorLoc = glGetUniformLocation(ourShader.getProgram(), "lightColor")
  var ambientLightLoc = glGetUniformLocation(ourShader.getProgram(), "light.ambient")
  var diffuseLightLoc = glGetUniformLocation(ourShader.getProgram(), "light.diffuse")
  var specularLightLoc = glGetUniformLocation(ourShader.getProgram(), "light.specular")
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
  var cameraPositionLoc = glGetUniformLocation(ourShader.getProgram(), "cameraPosition")
  glUniform3f(cameraPositionLoc, pCamera.position.x, pCamera.position.y, pCamera.position.z)

  var specularStrengthLoc = glGetUniformLocation(ourShader.getProgram(), "material.specular")
  withUnsafePointer(to: &specularStrength, {
	  $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { specularStrengthP in
	  	glUniform3f(specularStrengthLoc, specularStrength.x, specularStrength.y, specularStrength.z)}
  })

  var shininessLoc = glGetUniformLocation(ourShader.getProgram(), "material.shininess")
  glUniform1f(shininessLoc, GLfloat(shininess))

  var diffLoc = glGetUniformLocation(ourShader.getProgram(), "diff")
  glUniform1f(diffLoc, GLfloat(diff))

  var ambientStrengthLoc = glGetUniformLocation(ourShader.getProgram(), "material.ambient")
  withUnsafePointer(to: &ambientStrength, {
	  $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { ambientStrengthP in
	  	glUniform3f(ambientStrengthLoc, ambientStrength.x, ambientStrength.y, ambientStrength.z)}
  })
  var diffuseStrengthLoc = glGetUniformLocation(ourShader.getProgram(), "material.diffuse")
  withUnsafePointer(to: &diffuseStrength, {
	  $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { diffuseStrengthP in
		  glUniform3f(diffuseStrengthLoc, diffuseStrength.x, diffuseStrength.y, diffuseStrength.z)}
  })
	var lightPositionLoc = glGetUniformLocation(ourShader.getProgram(), "LightPosition")
	withUnsafePointer(to: &lightPosition, {
		$0.withMemoryRebound(to: GLfloat.self, capacity: 1) { lightPositionP in
			glUniform4f(lightPositionLoc, lightPosition.x, lightPosition.y, lightPosition.z, lightPosition.w)}
		})
	var lightDirLoc = glGetUniformLocation(ourShader.getProgram(), "light.direction")
	glUniform4f(lightDirLoc,lightDirection.x, lightDirection.y, lightDirection.z , lightDirection.w)
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
    model = SGLMath.translate(model, modelPosition)
	model = SGLMath.scale(model, vec3(0.2, 0.2, 0.2))
    withUnsafePointer(to: &model, {
  	  $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { modelP in
  	  	glUniformMatrix4fv(modelLoc, 1, GLboolean(GL_FALSE), modelP)}
    })
	var transInvLoc = glGetUniformLocation(ourShader.getProgram(), "transInv")
	var transInv: mat3
	if(ourShaderName == "phongVShader" || ourShaderName == "phongVShaderPoint"){
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

	/*
//start drawing the first debug cube

	phongShaderPointDebug.use()

    lightColorLoc = glGetUniformLocation(phongShaderPointDebug.getProgram(), "lightColor")
    ambientLightLoc = glGetUniformLocation(phongShaderPointDebug.getProgram(), "light.ambient")
    diffuseLightLoc = glGetUniformLocation(phongShaderPointDebug.getProgram(), "light.diffuse")
    specularLightLoc = glGetUniformLocation(phongShaderPointDebug.getProgram(), "light.specular")
    glUniform3f(ambientLightLoc, ambientColor.x, ambientColor.y, ambientColor.z)
    glUniform3f(diffuseLightLoc, diffuseColor.x, diffuseColor.y, diffuseColor.z)
    glUniform3f(specularLightLoc, 1.0, 1.0, 1.0)
    if(!lightsOff){
  	  glUniform3f(lightColorLoc, lightColor.x, lightColor.y, lightColor.z)
    }
    else{
  	  glUniform3f(lightColorLoc, 0.0, 0.0, 0.0)
    }
    cameraPositionLoc = glGetUniformLocation(phongShaderPointDebug.getProgram(), "cameraPosition")
    glUniform3f(cameraPositionLoc, pCamera.position.x, pCamera.position.y, pCamera.position.z)

    specularStrengthLoc = glGetUniformLocation(phongShaderPointDebug.getProgram(), "material.specular")
    withUnsafePointer(to: &specularStrength, {
  	  $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { specularStrengthP in
  	  	glUniform3f(specularStrengthLoc, specularStrength.x, specularStrength.y, specularStrength.z)}
    })

    shininessLoc = glGetUniformLocation(phongShaderPointDebug.getProgram(), "material.shininess")
    glUniform1f(shininessLoc, GLfloat(shininess))

    diffLoc = glGetUniformLocation(phongShaderPointDebug.getProgram(), "diff")
    glUniform1f(diffLoc, GLfloat(diff))

    ambientStrengthLoc = glGetUniformLocation(phongShaderPointDebug.getProgram(), "material.ambient")
    withUnsafePointer(to: &ambientStrength, {
  	  $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { ambientStrengthP in
  	  	glUniform3f(ambientStrengthLoc, ambientStrength.x, ambientStrength.y, ambientStrength.z)}
    })
    diffuseStrengthLoc = glGetUniformLocation(phongShaderPointDebug.getProgram(), "material.diffuse")
    withUnsafePointer(to: &diffuseStrength, {
  	  $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { diffuseStrengthP in
  		  glUniform3f(diffuseStrengthLoc, diffuseStrength.x, diffuseStrength.y, diffuseStrength.z)}
    })
  	lightPositionLoc = glGetUniformLocation(phongShaderPointDebug.getProgram(), "LightPosition")
  	withUnsafePointer(to: &lightPosition, {
  		$0.withMemoryRebound(to: GLfloat.self, capacity: 1) { lightPositionP in
  			glUniform4f(lightPositionLoc, lightPosition.x, lightPosition.y, lightPosition.z, lightPosition.w)}
  		})
  	lightDirLoc = glGetUniformLocation(phongShaderPointDebug.getProgram(), "light.direction")
  	glUniform4f(lightDirLoc,lightDirection.x, lightDirection.y, lightDirection.z , lightDirection.w)
    viewLoc = glGetUniformLocation(phongShaderPointDebug.getProgram(), "view")
    withUnsafePointer(to: &view, {
  	  $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { viewP in
  	  	glUniformMatrix4fv(viewLoc, 1, GLboolean(GL_FALSE), viewP)}
    })
    projectionLoc = glGetUniformLocation(phongShaderPointDebug.getProgram(), "projection")
    withUnsafePointer(to: &projection, {
  	  $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { projectionP in
  	  	glUniformMatrix4fv(projectionLoc, 1, GLboolean(GL_FALSE), projectionP)}
    })
    //used to have this last iteration
  //  glBindVertexArray(VAO)
    modelLoc = glGetUniformLocation(phongShaderPointDebug.getProgram(), "model")
	var debugCube = mat4()
	debugCube = SGLMath.translate(debugCube, modelPosition2)
	debugCube = SGLMath.scale(debugCube, vec3(0.2, 0.2, 0.2))
	withUnsafePointer(to: &debugCube, {
		$0.withMemoryRebound(to: GLfloat.self, capacity: 1) { dCubeP in
			glUniformMatrix4fv(modelLoc, 1, GLboolean(GL_FALSE), dCubeP)}
	})
  	transInvLoc = glGetUniformLocation(phongShaderPointDebug.getProgram(), "transInv")
  	transInv = mat3(transpose(inverse(view * model)))
  	withUnsafePointer(to: &transInv, {
  		$0.withMemoryRebound(to: GLfloat.self, capacity: 1) { transInvP in
  			glUniformMatrix3fv(transInvLoc, 1, GLboolean(GL_FALSE), transInvP)}
  	})
	debugModel.draw(phongShaderPointDebug)
//	glBindVertexArray(lightVAO)
//	glDrawArrays(GLenum(GL_TRIANGLES), 0, 36)

	/*Start Drawing the light itself */


	//end of first debug cube
	//second debug cube
		phongShaderPointDebug2.use()

	    lightColorLoc = glGetUniformLocation(phongShaderPointDebug2.getProgram(), "lightColor")
	    ambientLightLoc = glGetUniformLocation(phongShaderPointDebug2.getProgram(), "light.ambient")
	    diffuseLightLoc = glGetUniformLocation(phongShaderPointDebug2.getProgram(), "light.diffuse")
	    specularLightLoc = glGetUniformLocation(phongShaderPointDebug2.getProgram(), "light.specular")
	    glUniform3f(ambientLightLoc, ambientColor.x, ambientColor.y, ambientColor.z)
	    glUniform3f(diffuseLightLoc, diffuseColor.x, diffuseColor.y, diffuseColor.z)
	    glUniform3f(specularLightLoc, 1.0, 1.0, 1.0)
	    if(!lightsOff){
	  	  glUniform3f(lightColorLoc, lightColor.x, lightColor.y, lightColor.z)
	    }
	    else{
	  	  glUniform3f(lightColorLoc, 0.0, 0.0, 0.0)
	    }
	    cameraPositionLoc = glGetUniformLocation(phongShaderPointDebug2.getProgram(), "cameraPosition")
	    glUniform3f(cameraPositionLoc, pCamera.position.x, pCamera.position.y, pCamera.position.z)

	    specularStrengthLoc = glGetUniformLocation(phongShaderPointDebug2.getProgram(), "material.specular")
	    withUnsafePointer(to: &specularStrength, {
	  	  $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { specularStrengthP in
	  	  	glUniform3f(specularStrengthLoc, specularStrength.x, specularStrength.y, specularStrength.z)}
	    })

	    shininessLoc = glGetUniformLocation(phongShaderPointDebug2.getProgram(), "material.shininess")
	    glUniform1f(shininessLoc, GLfloat(shininess))

	    diffLoc = glGetUniformLocation(phongShaderPointDebug2.getProgram(), "diff")
	    glUniform1f(diffLoc, GLfloat(diff))

	    ambientStrengthLoc = glGetUniformLocation(phongShaderPointDebug2.getProgram(), "material.ambient")
	    withUnsafePointer(to: &ambientStrength, {
	  	  $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { ambientStrengthP in
	  	  	glUniform3f(ambientStrengthLoc, ambientStrength.x, ambientStrength.y, ambientStrength.z)}
	    })
	    diffuseStrengthLoc = glGetUniformLocation(phongShaderPointDebug2.getProgram(), "material.diffuse")
	    withUnsafePointer(to: &diffuseStrength, {
	  	  $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { diffuseStrengthP in
	  		  glUniform3f(diffuseStrengthLoc, diffuseStrength.x, diffuseStrength.y, diffuseStrength.z)}
	    })
	  	lightPositionLoc = glGetUniformLocation(phongShaderPointDebug2.getProgram(), "LightPosition")
	  	withUnsafePointer(to: &lightPosition, {
	  		$0.withMemoryRebound(to: GLfloat.self, capacity: 1) { lightPositionP in
	  			glUniform4f(lightPositionLoc, lightPosition.x, lightPosition.y, lightPosition.z, lightPosition.w)}
	  		})
	  	lightDirLoc = glGetUniformLocation(phongShaderPointDebug2.getProgram(), "light.direction")
	  	glUniform4f(lightDirLoc,lightDirection.x, lightDirection.y, lightDirection.z , lightDirection.w)
	    viewLoc = glGetUniformLocation(phongShaderPointDebug2.getProgram(), "view")
	    withUnsafePointer(to: &view, {
	  	  $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { viewP in
	  	  	glUniformMatrix4fv(viewLoc, 1, GLboolean(GL_FALSE), viewP)}
	    })
	    projectionLoc = glGetUniformLocation(phongShaderPointDebug2.getProgram(), "projection")
	    withUnsafePointer(to: &projection, {
	  	  $0.withMemoryRebound(to: GLfloat.self, capacity: 1) { projectionP in
	  	  	glUniformMatrix4fv(projectionLoc, 1, GLboolean(GL_FALSE), projectionP)}
	    })
	    //used to have this last iteration
	  //  glBindVertexArray(VAO)
	    modelLoc = glGetUniformLocation(phongShaderPointDebug2.getProgram(), "model")
		debugCube = mat4()
		debugCube = SGLMath.translate(debugCube, modelPosition3)
		debugCube = SGLMath.scale(debugCube, vec3(0.2, 0.2, 0.2))
		withUnsafePointer(to: &debugCube, {
			$0.withMemoryRebound(to: GLfloat.self, capacity: 1) { dCubeP in
				glUniformMatrix4fv(modelLoc, 1, GLboolean(GL_FALSE), dCubeP)}
		})
	  	transInvLoc = glGetUniformLocation(phongShaderPointDebug2.getProgram(), "transInv")
	  	transInv = mat3(transpose(inverse(view * model)))
	  	withUnsafePointer(to: &transInv, {
	  		$0.withMemoryRebound(to: GLfloat.self, capacity: 1) { transInvP in
	  			glUniformMatrix3fv(transInvLoc, 1, GLboolean(GL_FALSE), transInvP)}
	  	})
		debugModel.draw(phongShaderPointDebug2)
	//	glBindVertexArray(lightVAO)
	//	glDrawArrays(GLenum(GL_TRIANGLES), 0, 36)

		/*Start Drawing the light itself */

	//end of second debug cube

*/

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
    light = SGLMath.translate(light, vec3(lightPosition.x, lightPosition.y, lightPosition.z))
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

		if(keys[Int(GLFW_KEY_R)]){
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
			if keys[Int(GLFW_KEY_3)] {
				ourShaderName = "phongShaderPoint"
			}
			if keys[Int(GLFW_KEY_4)] {
				ourShaderName = "phongVShaderPoint"
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
    if keys[Int(GLFW_KEY_W)] {
		modelPosition.z -= 0.1
    }
    if keys[Int(GLFW_KEY_S)] {
		modelPosition.z += 0.1
    }
    if keys[Int(GLFW_KEY_A)] {
		modelPosition.x -= 0.1
    }
    if keys[Int(GLFW_KEY_D)] {
		modelPosition.x += 0.1
    }
/*    if keys[Int(GLFW_KEY_Y)] {
		UInt32.z -= 0.1
    }
    if keys[Int(GLFW_KEY_H)] {
		modelPosition2.z += 0.1
    }
    if keys[Int(GLFW_KEY_G)] {
		modelPosition2.x -= 0.1
    }
    if keys[Int(GLFW_KEY_J)] {
		modelPosition2.x += 0.1
    }
    if keys[Int(GLFW_KEY_T)] {
		modelPosition2.y -= 0.1
    }
    if keys[Int(GLFW_KEY_U)] {
		modelPosition2.y += 0.1
    }
	*/
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
