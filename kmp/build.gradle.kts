import org.jetbrains.kotlin.gradle.plugin.mpp.apple.XCFramework

plugins {
    kotlin("multiplatform")
    id("dev.petuska.npm.publish")
    `maven-publish`
}

group = providers.environmentVariable("GROUP").getOrElse("tech.notifly")
version = providers.environmentVariable("VERSION").getOrElse("0.1.0-alpha.1")

kotlin {
    jvm()

    js(IR) {
        nodejs()
        binaries.library()
        generateTypeScriptDefinitions()
    }

    val xcframework = XCFramework("NotiflyKMP")
    listOf(
        iosArm64(),
        iosSimulatorArm64(),
        iosX64(),
    ).forEach { target ->
        target.binaries.framework {
            baseName = "NotiflyKMP"
            isStatic = true
            xcframework.add(this)
        }
    }

    sourceSets {
        commonTest.dependencies {
            implementation(kotlin("test"))
        }
    }
}

npmPublish {
    packages {
        named("js") {
            packageName = "notifly-kmp-sdk"
            version = project.version.toString()
            readme = rootProject.file("README.md")
            files {
                from(rootProject.file("LICENSE"))
            }

            packageJson {
                license = "MIT"
                description = "Shared Kotlin Multiplatform implementation used by the Notifly SDKs"
                repository {
                    type = "git"
                    url = "https://github.com/team-michael/notifly-kmp-sdk.git"
                }
            }
        }
    }
}
