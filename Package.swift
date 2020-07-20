// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TransmissionRPC",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "TransmissionRPC",
            type: .dynamic,
            targets: ["TransmissionRPC"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "Categorization", url: "https://github.com/jvega1976/Categorization.git", from: "3.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "TransmissionRPC",
            dependencies: [],
            path: "Sources",
            swiftSettings: [
                .define("BUILD_LIBRARY_FOR_DISTRIBUTION=YES", .when(configuration: .release)),
                .define("LOCALIZED_STRING_SWIFTUI_SUPPORT=YES", .when(configuration: .release)),
                .define("COPY_PHASE_STRIP=NO",
                    .when(configuration: .debug)),
                .define("GCC_GENERATE_DEBUGGING_SYMBOLS=YES",
                    .when(configuration: .debug)),
                .define("DEBUG_INFORMATION_FORMAT=dwarf-with-dsym",
                    .when(configuration: .debug)),
                .define("GCC_SYMBOLS_PRIVATE_EXTERN=NO",
                    .when(configuration: .debug)),
                .define("KEEP_PRIVATE_EXTERNS=YES",
                    .when(configuration: .debug)),
                .define("STRIP_SWIFT_SYMBOLS=NO",
                    .when(configuration: .debug)),
                .define("STRIP_INSTALLED_PRODUCT=NO",
                    .when(configuration: .debug)),
        ]),
        .testTarget(
            name: "TransmissionRPCTests",
            dependencies: ["TransmissionRPC","Categorization"]),
    ]
)
