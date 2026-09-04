// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "NotiflyKMP",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "NotiflyKMP",
            targets: ["NotiflyKMP"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "NotiflyKMP",
            url: "https://github.com/team-michael/notifly-kmp-sdk/releases/download/v0.1.0-alpha.1/NotiflyKMP.xcframework.zip",
            checksum: "206c42420b25d912efee225ad120f747999336845ff05793da583c27e0b6a003"
        ),
    ]
)
