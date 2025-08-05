// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ThermalMonitor",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .executable(
            name: "ThermalMonitor",
            targets: ["ThermalMonitor"]
        ),
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "ThermalMonitor",
            dependencies: [],
            path: "ThermalMonitor/Sources"
        ),
    ]
)