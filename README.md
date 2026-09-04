# Notifly KMP SDK

Shared Kotlin Multiplatform implementation used internally by the Notifly Android, iOS, and JavaScript SDKs.

The repository contains one `:kmp` umbrella module. Platform SDKs keep their existing public APIs and delegate selected deterministic behavior to this module.

## Current scope

- `tech.notifly.kmp.identity.UserIdTransitionPolicy`
- JVM, Kotlin/JS IR, iOS device, and iOS simulator targets
- Static `NotiflyKMP.xcframework`

## Verify

```bash
./gradlew \
  :kmp:jvmTest \
  :kmp:jsNodeTest \
  :kmp:iosSimulatorArm64Test \
  --no-daemon
```

## Versioning

Host SDKs must depend on an exact tagged version. Moving branches and version ranges are not supported.

## Artifacts

One tag produces three platform-facing artifacts:

- Android/JVM: `com.github.team-michael.notifly-kmp-sdk:kmp:<tag>` through JitPack
- JavaScript: `@notifly/kmp-sdk` through npm
- iOS: `NotiflyKMP` through Swift Package Manager or CocoaPods

The initial prerelease version is `v0.1.0-alpha.1`. These artifacts are internal implementation dependencies of the platform SDKs; application developers should continue to install the platform SDK they already use.
