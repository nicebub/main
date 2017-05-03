// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "main",

	dependencies: [
		.Package( url:  "https://github.com/nicebub/OpenGL.git" , Version(1,0,5)),
        .Package(url: "https://github.com/cpjuank/Image.git", Version(3,0,5)),
		.Package(url: "https://github.com/kosua20/CGLFW3.git", Version(1,4,2)),
		.Package(url: "https://github.com/cpjuank/Math.git", Version(1,0,5)),
		.Package(url: "https://github.com/mgadda/CAssimp", versions: Version(0,1,3)..<Version(0,1,4))
	]
	)
