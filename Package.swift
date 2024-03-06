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
        .library(name: "AliyunLogURLSessionInstrumentation", targets: ["AliyunLogURLSessionInstrumentation"]),
        .library(name: "AliyunLogCrashReporter", targets: ["AliyunLogCrashReporter"]),
        .library(name: "AliyunLogNetworkDiagnosis", targets: ["AliyunLogNetworkDiagnosis"]),
        .library(name: "AliyunLogOtlpExporter", targets: ["AliyunLogOtlpExporter"]),
        .library(name: "AliyunLogCrashReporter2", targets: ["AliyunLogCrashReporter2", "WPKMobiWrapper"]),
        .library(name: "AliyunLogOTelCommon", targets: ["AliyunLogOTelCommon"]),
//        .library(name: "WPKMobi", targets: ["WPKMobi"]),
//        .library(name: "AliNetworkDiagnosis", targets: ["AliNetworkDiagnosis"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/open-telemetry/opentelemetry-swift", from: "1.6.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "aliyun-log-c-sdk",
            path: "Sources/",
            sources: ["aliyun-log-c-sdk/"],
            publicHeadersPath: "aliyun-log-c-sdk/include/"
        ),
        .target(
            name: "AliyunLogProducer",
            dependencies: ["aliyun-log-c-sdk"],
            path: "Sources",
            exclude: [
                "Producer/Info.plist"
            ],
            sources: [
                "Producer/"
            ],
            publicHeadersPath: "Producer/include/"
        ),
        .target(
            name: "AliyunLogOTSwift",
            path: "Sources",
            exclude: [
                "OTSwift/Info.plist"
            ],
            sources: [
                "OTSwift/"
            ],
            publicHeadersPath: "OTSwift/include/"
        ),
        .target(
            name: "AliyunLogOT",
            dependencies: ["AliyunLogOTSwift"],
            path: "Sources",
            exclude: [
                "OT/Info.plist"
            ],
            sources: [
                "OT/", "OT/Logs/"
            ],
            publicHeadersPath: "OT/include/"
        ),
        .target(
            name: "AliyunLogCore",
            dependencies: ["AliyunLogProducer", "AliyunLogOT", "AliyunLogOTSwift"],
            path: "Sources",
            exclude: [
                "Core/Info.plist"
            ],
            sources: [
                "Core/"
            ],
            publicHeadersPath: "Core/include/"
        ),
        .target(
            name: "AliyunLogTrace",
            dependencies: ["AliyunLogCore"],
            path: "Sources",
            exclude: [
                "Trace/Info.plist"
            ],
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
        ),
        .target(
            name: "AliyunLogCrashReporter",
            dependencies: ["AliyunLogCore", "AliyunLogOT", "AliyunLogTrace"],
            path: "Sources",
            sources: [
                "CrashReporter/"
            ],
            publicHeadersPath: "CrashReporter/include",
            linkerSettings: [
//                .linkedFramework("CoreGraphics")
            ]
        ),
        .target(
            name: "Unity4SLS",
            path: "Sources",
            sources: [
                "Unity4SLS/"
            ],
            publicHeadersPath: "Unity4SLS/include"
        ),
        .target(
            name: "SLSIPA4Unity",
            path: "Sources",
            sources: [
                "SLSIPA4Unity/"
            ],
            publicHeadersPath: "SLSIPA4Unity/include"
        ),
        .target(
            name: "AliyunLogNetworkDiagnosis",
            dependencies: ["AliyunLogCore", "AliyunLogOT", "AliNetworkDiagnosis"],
            path: "Sources",
            sources: [
                "NetworkDiagnosis/"
            ],
            publicHeadersPath: "NetworkDiagnosis/include"
        ),
        .target(
            name: "AliyunLogCrashReporter2",
            dependencies: [
                "WPKMobiWrapper",
                "AliyunLogOtlpExporter",
                "AliyunLogOTelCommon",
                .product(name: "OpenTelemetrySdk", package: "opentelemetry-swift")
            ],
            path: "Sources",
            sources: [
                "CrashReporter2/"
            ]
        ),
        .target(
            name: "AliyunLogOtlpExporter",
            dependencies: [
                "AliyunLogProducer",
                "AliyunLogOTelCommon",
                .product(name: "OpenTelemetryApi", package: "opentelemetry-swift"),
                .product(name: "OpenTelemetrySdk", package: "opentelemetry-swift")
            ],
            path: "Sources",
            sources: [
                "OtlpExporter/"
            ],
            publicHeadersPath: "OtlpExporter/include"
        ),
        .target(
            name: "WPKMobiWrapper",
            dependencies: ["WPKMobi"],
            path: "Sources",
            sources: [
                "WPKMobiWrapper/"
            ],
            publicHeadersPath: "WPKMobiWrapper/include"
        ),
        .target(
            name: "AliyunLogOTelCommon",
            dependencies: [
                .product(name: "OpenTelemetrySdk", package: "opentelemetry-swift")
            ],
            path: "Sources",
            sources: [
                "OTelCommon/"
            ]
        ),
        .binaryTarget(
            name: "WPKMobi",
            path: "Sources/WPKMobi/WPKMobi.xcframework"
        ),
        .binaryTarget(
            name: "AliNetworkDiagnosis",
            path: "Sources/AliNetworkDiagnosis/AliNetworkDiagnosis.xcframework"
        ),
//        .binaryTarget(
//            name: "OpenTelemetryApi",
//            path: "Sources/OpenTelemetryApi/OpenTelemetryApi.xcframework"
//        ),
//
//        .binaryTarget(
//            name: "OpenTelemetrySdk",
//            path: "Sources/OpenTelemetrySdk/OpenTelemetrySdk.xcframework"
//        )
    ]
)
