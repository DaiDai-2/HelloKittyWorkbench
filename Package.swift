// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "HelloKittyWorkbench",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "HelloKittyWorkbench",
            targets: ["HelloKittyWorkbench"]),
    ],
    dependencies: [
        // 如果使用 Supabase Swift SDK，在这里添加依赖
        // .package(url: "https://github.com/supabase-community/supabase-swift.git", from: "0.3.0"),
    ],
    targets: [
        .target(
            name: "HelloKittyWorkbench",
            dependencies: [],
            path: "HelloKittyWorkbench"
        ),
    ]
)
