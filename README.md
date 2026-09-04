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
