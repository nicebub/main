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

enum Camera_Movement {
  case forward
  case backward
  case left
  case right
}

let YAW: GLfloat = -90.0
let PITCH: GLfloat = 0.0
let SPEED: GLfloat = 5.0
let SENSITIVITY: GLfloat = 0.25
let ZOOM: GLfloat = 45.0

class Camera {
	var position: vec3
	var front: vec3
	var up: vec3
	var right: vec3
	var worldUp: vec3

	var yaw: GLfloat
	var pitch: GLfloat

	var movementSpeed: GLfloat?
	var mouseSensitivity: GLfloat?
	var zoom: GLfloat?

    init(inPosition: vec3 = vec3(0.0, 0.0, 0.0), inUp: vec3 = vec3(0.0, 1.0, 0.0),
              inYaw: GLfloat = YAW, inPitch: GLfloat = PITCH, _ inFront: vec3 = vec3(0.0, 0.0, -1.0),
              _ inMovementSpeed: GLfloat = SPEED, _ inMouseSensitivity: GLfloat = SENSITIVITY,
              _ inZoom: GLfloat = ZOOM){
        position = inPosition
        worldUp = inUp
        up = vec3()
        right = vec3()
        yaw = inYaw
        pitch = inPitch
        front = inFront
        movementSpeed = inMovementSpeed
        mouseSensitivity = inMouseSensitivity
        zoom = inZoom
        self.updateCameraVectors()
    }
    init(posX: GLfloat, posY: GLfloat, posZ: GLfloat, upX: GLfloat, upY: GLfloat, upZ: GLfloat, inYaw: GLfloat, inPitch: GLfloat, _ inFront: vec3? = vec3(0.0, 0.0, -1.0),
              _ inMovementSpeed: GLfloat? = SPEED, _ inMouseSensitivity: GLfloat? = SENSITIVITY,
              _ inZoom: GLfloat? = ZOOM){
        position = vec3(posX, posY, posZ)
        worldUp = vec3( upX, upY, upZ)
        yaw = inYaw
        pitch = inPitch
        front = vec3()
        up = vec3()
        right = vec3()
        movementSpeed = inMovementSpeed
        mouseSensitivity = inMouseSensitivity
        zoom = inZoom
        self.updateCameraVectors()
    }
    func getViewMatrix() -> mat4 {
        return SGLMath.lookAt(position, position + front, up)
    }
    func processKeyboard(direction: Camera_Movement, deltaTime: GLfloat){
        let velocity: GLfloat = movementSpeed! * deltaTime
        switch direction{
        case .forward:
 //               position += front * velocity
 				position += normalize(cross(up, right)) * velocity
        case .backward:
				position -= normalize(cross(up, right)) * velocity
//                position -= front * velocity
        case .left:
                position -= right * velocity
        case .right:
                position += right * velocity
        }
//		position.y = 0.0
    }
    func processMouseMovement(xoffset: GLfloat, yoffset: GLfloat, constrainPitch: GLboolean = GLboolean(GL_TRUE)){
        let newX: GLfloat = xoffset * mouseSensitivity!
        let newY: GLfloat = yoffset * mouseSensitivity!
        yaw  = GLfloat((yaw + newX).truncatingRemainder(dividingBy: 360.0))
        pitch += newY
        if(constrainPitch == GLboolean(GL_TRUE)){
            if(pitch > 89.0){
                pitch = 89.0
            }
            if(pitch < -89.0){
                pitch = -89.0
            }

        }
        self.updateCameraVectors()
    }
    func processMouseScroll(yoffset: GLfloat){
        if(zoom! >= GLfloat(1.0) && zoom! <= GLfloat(45.0)){
            zoom = zoom! - yoffset
        }
        else if(zoom! <= GLfloat(1.0)){
            zoom = 1.0
        }
        else if(zoom! >= GLfloat(45.0)){
            zoom = 45.0
        }
    }

    func updateCameraVectors(){
    var front: vec3 = vec3()
    front.x = cos(radians(yaw)) * cos(radians(pitch))
    front.y = sin(radians(pitch))
    front.z = sin(radians(yaw)) * cos(radians(pitch))
    self.front = normalize(front)
    right = normalize(cross(self.front, worldUp))
    up = normalize(cross(right, self.front))
    }

}
