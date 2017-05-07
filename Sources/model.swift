import OpenGL
import SGLMath
import Foundation
import SGLImage

class Model{
     var meshes: [Mesh]
     var directory: String
	 var textures_loaded: [Texture]
	 var materials: [Material]

 init(path: String){
	 meshes = []
	 directory = ""
    textures_loaded = []
	materials = []
	 loadModel(path)
 }
 public func draw(_ shader: Shader){
	 for mesh in meshes {
		 mesh.draw(shader: shader)
	 }
 }

 private func loadModel(_ path: String){
let aiProcess_Triangulate = 0x8
let aiProcess_FlipUVs = 0x800000
let AI_SCENE_FLAGS_INCOMPLETE = 0x1
    var scene: aiScene? = (aiImportFile(path, UInt32(aiProcess_Triangulate) | UInt32(aiProcess_FlipUVs))).pointee
	 if(scene == nil  || UInt32((scene?.mFlags)!) == UInt32(AI_SCENE_FLAGS_INCOMPLETE) || scene?.mRootNode == nil){
		 print("error: \(aiGetErrorString())")
		 return
	 }
     let url = URL(fileURLWithPath: path)
	 directory = (url.deletingLastPathComponent()).path
	 processNode(node: (scene?.mRootNode)!, scene: &scene)
	 aiReleaseImport( &scene! )
 }
 private func processNode(node: UnsafeRawPointer?, scene: UnsafeRawPointer?){
    if(node != nil && scene != nil){
	 let tNode: aiNode? = node?.assumingMemoryBound(to: aiNode.self).pointee
	 var tScene: aiScene = scene!.assumingMemoryBound(to: aiScene.self).pointee
    if(tNode?.mNumMeshes != 0){
	 for i in 1...Int((tNode?.mNumMeshes)!) {
		 var aMesh: aiMesh = tScene.mMeshes![Int(tNode!.mMeshes![Int(i) - 1])]!.pointee
		 meshes.append(processMesh(mesh: &aMesh, scene: scene!))
	 }
    }
    if(Int((tNode?.mNumChildren)!) != 0){
	 for child in 1...Int((tNode?.mNumChildren)!) {
		 processNode(node: (tNode?.mChildren[Int(child) - 1]!)!, scene: &tScene)
	 }
    }
    }
 }
 private func processMesh(mesh: UnsafeRawPointer, scene: UnsafeRawPointer) -> Mesh {
	 let newMesh = mesh.assumingMemoryBound(to: aiMesh.self)
	 let newScene = scene.assumingMemoryBound(to: aiScene.self)
    let eMesh: aiMesh = newMesh.pointee
    let eVertices = eMesh.mVertices
    let eNormals = eMesh.mNormals
	 var vertices: [Vertex] = [Vertex]()
	 var indices: [GLuint] = [GLuint]()
	 var textures: [Texture] = [Texture]()
	 for i in 0...newMesh.pointee.mNumVertices - 1 {
		 var vertex: Vertex = Vertex()
		 var vector: vec3 = vec3()
		 vector.x = (eVertices?[Int(i)].x)!
		 vector.y = (eVertices?[Int(i)].y)!
		 vector.z = (eVertices?[Int(i)].z)!
		 vertex.position = vector
        if(eNormals != nil){
            vector.x = (eNormals?[Int(i)].x)!
            vector.y = (eNormals?[Int(i)].y)!
            vector.z = (eNormals?[Int(i)].z)!
            vertex.normal = vector
        }
        else {
            vertex.normal = vec3(0.0, 0.0, 0.0)
        }
		 let mTex = eMesh.mTextureCoords
		 let (texture, _, _, _, _, _, _, _) = mTex
	     if(texture != nil){
			 var vec: vec2 = vec2()
			 vec.x = (texture?[Int(i)].x)!
			 vec.y = (texture?[Int(i)].y)!
			 vertex.texCoords = vec
		 }
		 else {
			 vertex.texCoords = vec2(0.0, 0.0)
		 }

		 vertices.append(vertex)
	 }
	 for i in 0...eMesh.mNumFaces - 1 {
	 	let face: aiFace = (eMesh.mFaces?[Int(i)])!
	 	for j in 0...face.mNumIndices - 1 {
	 		indices.append((face.mIndices?[Int(j)])!)
	 	}
	 }
	 if(newMesh.pointee.mMaterialIndex >= 0){
		 let eScene = newScene.pointee
        let material = eScene.mMaterials?[Int(newMesh.pointee.mMaterialIndex)]
        let diffuseMaps: [Texture] = loadMaterialTextures(mat: material, type: aiTextureType_DIFFUSE, typeName: "texture_diffuse")
				 textures += diffuseMaps
		 let specularMaps: [Texture] = loadMaterialTextures(mat: material, type: aiTextureType_SPECULAR, typeName: "texture_specular")
		 		 textures += specularMaps
	 }

	 return Mesh(inVertices: vertices, inIndices: indices, inTextures: textures)

 }
 private func loadMaterialTextures(mat: UnsafeRawPointer?, type: aiTextureType, typeName: String) -> [Texture] {
	 var newMat = mat?.assumingMemoryBound(to: aiMaterial.self).pointee
    var rTextures: [Texture] = [Texture]()
    let count = aiGetMaterialTextureCount(&newMat!, type)
    if(count != 0){
	 for i in 0...count - 1 {
		 var myString: aiString = aiString()
		 var myDiffuse: aiColor4D = aiColor4D(r: 0.0, g: 0.0, b: 0.0, a: 0.0)
		 aiGetMaterialTexture(&newMat!, type, i, &myString, nil, nil, nil, nil, nil, nil)
		 aiGetMaterialColor(&newMat!, "$clr.diffuse", 0, 0, &myDiffuse)
//		 print("the Material Diffuse Color: ", myDiffuse)
		 var skip: GLboolean = GLboolean(GL_FALSE)
        if(textures_loaded.count != 0){
		 for j in 0...textures_loaded.count - 1 {
            if(stringFromaiString(inString: textures_loaded[j].path) == stringFromaiString(inString: myString)){
				 rTextures.append(textures_loaded[j])
				 skip = GLboolean(GL_TRUE)
			 }
		 }
        }
		 if(skip == GLboolean(GL_FALSE)){
			 var iTexture: Texture = Texture()
			 iTexture.id = GLuint(textureFromFile(path: myString, inDirectory: directory))
			 iTexture.type = typeName
			 iTexture.path = myString
			 rTextures.append(iTexture)
			 textures_loaded.append(iTexture)
	 }
	 }
    }
    return rTextures
 }
}


func textureFromFile(path: aiString, inDirectory: String) -> GLuint {
    let aString: String =  stringFromaiString(inString: path)
	let filename: String = inDirectory +  "/" + aString
	var textureID: GLuint = 0
	glGenTextures(1, &textureID)

	glBindTexture(GLenum(GL_TEXTURE_2D), textureID)

	glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_REPEAT)
	glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_REPEAT)

	glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR_MIPMAP_LINEAR)
	glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
	let loader = SGLImageLoader(fromFile: filename)
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

    return textureID
}

func stringFromaiString(inString: aiString) -> String {
    let _: aiString = aiString()
    let _: UnsafePointer<UInt8> = UnsafePointer<UInt8>(bitPattern: Int(inString.data.0))!
    let length = inString.length
    let data = inString.data
    let _: UnsafePointer<UInt8> = UnsafePointer<UInt8>(bitPattern: Int(data.0))!
    var myString2 = String()
    if(length != 0){
        let mirror = Mirror(reflecting: data)
		for (_, value) in mirror.children {
            if(value as! Int8 == 0){
                continue
            }
            myString2.append(Character(UnicodeScalar(Int(value as! Int8))!))
        }
    }
    return myString2
}
