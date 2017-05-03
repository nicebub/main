import OpenGL
import SGLMath
import Foundation
import SGLImage

class Model{
     var meshes: [Mesh]
     var directory: String
	 var textures_loaded: [Texture]

 init(path: String){
	 meshes = []
	 directory = ""
    textures_loaded = []
//	 print("The path is: ", path)
	 loadModel(path)
 }
 public func draw(_ shader: Shader){
//	 print("DRAWING MODEL")
	 for mesh in meshes {
//		 print("Going to draw a mesh")
		 mesh.draw(shader: shader)
//		 print("finished drawing a mesh")
	 }
//	 print("FINISHED DRAWING MODEL")
 }

 private func loadModel(_ path: String){
//	 var importer: Importer
let aiProcess_Triangulate = 0x8
let aiProcess_FlipUVs = 0x800000
let AI_SCENE_FLAGS_INCOMPLETE = 0x1
//print("The path is: ", path)
    var scene: aiScene? = (aiImportFile(path, UInt32(aiProcess_Triangulate) | UInt32(aiProcess_FlipUVs))).pointee
//    var scene: aiScene? = (aiImportFile(path, UInt32(aiProcess_Triangulate))).pointee
	 //let scene: aiScene = &scenePointer
//	 print("the scene object info: scene itslef and scene.mRootNode", scene, scene?.mRootNode)
	 if(scene == nil  || UInt32((scene?.mFlags)!) == UInt32(AI_SCENE_FLAGS_INCOMPLETE) || scene?.mRootNode == nil){
//		 print("Made it into the error section")
		 print("error: \(aiGetErrorString())")
		 return
	 }
//	 print("passed this far")
     let url = URL(fileURLWithPath: path)
	 directory = (url.deletingLastPathComponent()).path
//	 print("The directory is: \(directory)")
 //   print("scene?.mRootNode)!", (scene?.mRootNode)!)
//    print("scene \(scene)")
//    print("scene?.mFlags", scene?.mFlags)
	 processNode(node: (scene?.mRootNode)!, scene: &scene)
	 aiReleaseImport( &scene! )
 }
 private func processNode(node: UnsafeRawPointer, scene: UnsafeRawPointer){
    if(node != nil && scene != nil){
//    print("Iterating...potentially again")
//        print("node.assumingMemoryBound(to: aiNode.self)", node.assumingMemoryBound(to: aiNode.self))
 //       print("node.assumingMemoryBound(to: aiNode.self.pointee)", node.assumingMemoryBound(to: aiNode.self).pointee)
	 let tNode: aiNode? = node.assumingMemoryBound(to: aiNode.self).pointee
	 var tScene: aiScene = scene.assumingMemoryBound(to: aiScene.self).pointee
//	 print("tScene an aiScene: \(tScene)", tScene)
//	 print("tNode an aiNode: \(tNode)", tNode)
//    print("tNode.mNumMeshes", tNode?.mNumMeshes)
    if(tNode?.mNumMeshes != 0){
	 for i in 1...Int((tNode?.mNumMeshes)!) {
//        print("tScene.mMeshes",tScene.mMeshes)
		 var aMesh: aiMesh = tScene.mMeshes![Int(tNode!.mMeshes![Int(i) - 1])]!.pointee
		 meshes.append(processMesh(mesh: &aMesh, scene: scene))
	 }
    }
 //   print("tNode?.mNumChildren", tNode?.mNumChildren)
    if(Int((tNode?.mNumChildren)!) != 0){
 //       print("I found a child?")
	 for child in 1...Int((tNode?.mNumChildren)!) {
		 processNode(node: (tNode?.mChildren[Int(child) - 1]!)!, scene: &tScene)
	 }
    }
    }
 }
 private func processMesh(mesh: UnsafeRawPointer, scene: UnsafeRawPointer) -> Mesh {
	 let newMesh = mesh.assumingMemoryBound(to: aiMesh.self)
	 let newScene = scene.assumingMemoryBound(to: aiScene.self)
//    print("Mesh: mesh", mesh)
//    print("newMesh", newMesh)
//    print("newMesh.pointee", newMesh.pointee)
//    print("extra play", (newMesh.pointee).mVertices.pointee)
//    print("extra extra", (newMesh.pointee).mVertices[1])
    let eMesh: aiMesh = newMesh.pointee
    let eVertices = eMesh.mVertices
    let eNormals = eMesh.mNormals
//    print("eVertices", eVertices as Any)
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
//		 print("Texture issuses: mTex: \(mTex)")
		 let (texture, _, _, _, _, _, _, _) = mTex
		// for (texture, _, _, _, _, _, _, _) in eMesh.mTextureCoords{
//			 print("texture", texture)
			 //}
//		 print("mTex", mTex)
//		 let saferTex =mTex.assumingMemoryBound(to: aiVector3D.self, capacity: mTex.count)
//		 print("mTex type", type(of:mTex))
//		 print("eMesh.mTextureCoords: \(eMesh.mTextureCoords)")
//		 print("eMesh.mTextureCoords: \(eMesh.mTextureCoords)")
	//	 print("mtex[0]", mTex[0])
	     if(texture != nil){
//			 print("texture: \(texture?)")
//		 print("found a texture coordinate")
			 var vec: vec2 = vec2()
			 vec.x = (texture?[Int(i)].x)!
			 vec.y = (texture?[Int(i)].y)!
//			 print("texture coordinates are: | vec.x | vec.y |")
//			 print("                         |  \(vec.x) | \(vec.y)")
			 vertex.texCoords = vec
		 }
		 else {
//			 print("Didn't find a texture coordinate, setting none.")
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
//		 print("Found Materials!")
		 let eScene = newScene.pointee
        let material = eScene.mMaterials?[Int(newMesh.pointee.mMaterialIndex)]
        let diffuseMaps: [Texture] = loadMaterialTextures(mat: material, type: aiTextureType_DIFFUSE, typeName: "texture_diffuse")
				 textures += diffuseMaps
		 let specularMaps: [Texture] = loadMaterialTextures(mat: material, type: aiTextureType_SPECULAR, typeName: "texture_specular")
		 		 textures += specularMaps
	 }

	 //var _: Mesh = Mesh(inVertices:[],inIndices: [],inTextures: [])
	 return Mesh(inVertices: vertices, inIndices: indices, inTextures: textures)

 }
 private func loadMaterialTextures(mat: UnsafeRawPointer?, type: aiTextureType, typeName: String) -> [Texture] {
	 var newMat = mat?.assumingMemoryBound(to: aiMaterial.self).pointee
 //   print("newMat \(String(describing: newMat))")
    var rTextures: [Texture] = [Texture]()
  //  rTextures.append(Texture())
//print("rTextures[0]", rTextures[0])
    let count = aiGetMaterialTextureCount(&newMat!, type)
    if(count != 0){
	 for i in 0...count - 1 {
       // print("aiGetMaterialTexturecCount", aiGetMaterialTextureCount(&newMat!, type) - 1 )
		 var myString: aiString = aiString()
		 aiGetMaterialTexture(&newMat!, type, i, &myString, nil, nil, nil, nil, nil, nil)
		 var skip: GLboolean = GLboolean(GL_FALSE)
        if(textures_loaded.count != 0){
		 for j in 0...textures_loaded.count - 1 {
            if(stringFromaiString(inString: textures_loaded[j].path) == stringFromaiString(inString: myString)){
//				print("Found a string match!")
//				print("textures_loaded had: ", stringFromaiString(inString: textures_loaded[j].path))
//				print("materialtexture had: ", stringFromaiString(inString: myString))
				 rTextures.append(textures_loaded[j])
				 skip = GLboolean(GL_TRUE)
			 }
		 }
        }
		 if(skip == GLboolean(GL_FALSE)){
//			 print("Initial Texture Load")
			 var iTexture: Texture = Texture()
			 //let newString = String()
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
//	print("texture name: \(aString)")
//	print("full texture url path: ", inDirectory + "/" + aString)
//    print("type of aiString", type(of: aiString()))
//    print("type of data from aiString", type(of: path.data))
	let filename: String = inDirectory +  "/" + aString
//	print("Loading Texture: \(filename)")
	var textureID: GLuint = 0
	glGenTextures(1, &textureID)

	glBindTexture(GLenum(GL_TEXTURE_2D), textureID)

	glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_REPEAT)
	glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_REPEAT)

	glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR_MIPMAP_LINEAR)
	glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
//print("filename", filename)
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

//	print("data of path", path.data)
//	print("c string?", C_Str(path))
//    print("inPath", path)
 //   print("inDirectory", inDirectory)
//	filename = inDirectory + "/" + filename
//	print("filename is: \(filename)")
    return textureID
}

func stringFromaiString(inString: aiString) -> String {
    let _: aiString = aiString()
//    var i = ""
    let _: UnsafePointer<UInt8> = UnsafePointer<UInt8>(bitPattern: Int(inString.data.0))!
//    print("this is the current aiString:", inString)
    let length = inString.length
    let data = inString.data
    let _: UnsafePointer<UInt8> = UnsafePointer<UInt8>(bitPattern: Int(data.0))!
//    print("length of aiString: \(length)")
    var myString2 = String()
    if(length != 0){
        let mirror = Mirror(reflecting: data)
		for (_, value) in mirror.children {
            if(value as! Int8 == 0){
                continue
            }
//            print("value: \(value), value type:", type(of: value))
            myString2.append(Character(UnicodeScalar(Int(value as! Int8))!))
//			print("myString: \(myString2)")
        }
    }
    return myString2
}
