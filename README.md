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

The Maven smoke test compiles and runs a consumer application with Kotlin `1.8.10`:

```bash
./gradlew :kmp:publishToMavenLocal --no-daemon
scripts/smoke-maven-local.sh
```

## Kotlin compatibility

The build uses Kotlin Gradle Plugin `2.2.21` for current Kotlin Multiplatform and Apple toolchain support. Published common and JVM code is restricted to Kotlin language/API version `1.8` and depends on Kotlin stdlib `1.8.10`, so the current Notifly Android SDK can consume it without upgrading from Kotlin `1.8.10`.

Kotlin/JS uses the stdlib matching the build compiler because the Kotlin/JS compiler requires it. This does not change the Kotlin requirement of the Android/JVM artifact.

## Versioning

Host SDKs must depend on an exact tagged version. Moving branches and version ranges are not supported.

## Artifacts

One tag produces three platform-facing artifacts:

- Android/JVM: `com.github.team-michael.notifly-kmp-sdk:kmp:<tag>` through JitPack
- JavaScript: `notifly-kmp-sdk` through npm
- iOS: `NotiflyKMP` through Swift Package Manager or CocoaPods

The initial prerelease version is `v0.1.0-alpha.1`. These artifacts are internal implementation dependencies of the platform SDKs; application developers should continue to install the platform SDK they already use.
