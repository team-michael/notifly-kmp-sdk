import org.jetbrains.kotlin.gradle.plugin.mpp.apple.XCFramework

plugins {
    kotlin("multiplatform")
    `maven-publish`
}

group = "tech.notifly"
version = "0.1.0-alpha.1"

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
