// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "DockerClient",
    products: [
        .library(name: "DockerClient", targets: ["DockerClient"])
    ],
    targets: [
        .target(name: "DockerClient", dependencies: ["Ccurl"]),
        .target(name: "Ccurl")
    ]
)
