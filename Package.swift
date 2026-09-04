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
            checksum: "492a0717c60d5e6db6f327e74d8beeafec0571f155ff7fb537db615cdd916d0b"
        ),
    ]
)
