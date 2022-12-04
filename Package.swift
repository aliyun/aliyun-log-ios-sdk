// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let package = Package(
    name: "AliyunLogProducer",
    platforms: [.iOS(.v10), .macOS(.v10_12), .tvOS(.v10),],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "AliyunLogProducer", targets: ["AliyunLogProducer"]),
        .library(name: "AliyunLogOT", targets: ["AliyunLogOT"]),
        .library(name: "AliyunLogOTSwift", targets: ["AliyunLogOTSwift"]),
        .library(name: "AliyunLogCore", targets: ["AliyunLogCore"]),
        .library(name: "AliyunLogTrace", targets: ["AliyunLogTrace"]),
        .library(name: "AliyunLogURLSessionInstrumentation", targets: ["AliyunLogURLSessionInstrumentation"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "aliyun-log-c-sdk",
            path: "Sources/",
            sources: ["aliyun-log-c-sdk/"],
            publicHeadersPath: "aliyun-log-c-sdk/include/",
            linkerSettings: [.linkedLibrary("z")]
        ),
        .target(
            name: "AliyunLogProducer",
            dependencies: ["aliyun-log-c-sdk"],
            path: "Sources",
            sources: [
                "Producer/"
            ],
            publicHeadersPath: "Producer/include/"
        ),
        .target(
            name: "AliyunLogOTSwift",
            path: "Sources",
            sources: [
                "OTSwift/"
            ],
            publicHeadersPath: "OTSwift/include/"
        ),
        .target(
            name: "AliyunLogOT",
            dependencies: ["AliyunLogOTSwift"],
            path: "Sources",
            sources: [
                "OT/"
            ],
            publicHeadersPath: "OT/include/"
        ),
        .target(
            name: "AliyunLogCore",
            dependencies: ["AliyunLogProducer", "AliyunLogOT", "AliyunLogOTSwift"],
            path: "Sources",
            sources: [
                "Core/"
            ],
            publicHeadersPath: "Core/include/"
        ),
        .target(
            name: "AliyunLogTrace",
            dependencies: ["AliyunLogCore"],
            path: "Sources",
            sources: [
                "Trace/"
            ],
            publicHeadersPath: "Trace/include/"
        ),
        .target(
            name: "AliyunLogURLSessionInstrumentation",
            dependencies: ["AliyunLogTrace", "AliyunLogOTSwift", "AliyunLogOT"],
            path: "Sources/Instrumentation",
            sources: [
                "URLSession/"
            ],
            publicHeadersPath: "URLSession/include/"
        )
//        .testTarget(
//            name: "aliyun-log-ios-sdk3Tests",
//            dependencies: ["aliyun-log-ios-sdk3"]),
    ]
)
