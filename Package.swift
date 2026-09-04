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
            checksum: "1f9329189ddf30cf242cead67996d8db4d360ce9b3801c279e2892b3c66cce60"
        ),
    ]
)
