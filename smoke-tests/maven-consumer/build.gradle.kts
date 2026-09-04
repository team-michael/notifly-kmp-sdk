plugins {
    kotlin("jvm") version "2.2.21"
}

dependencies {
    val notiflyKmpVersion = providers.environmentVariable("VERSION").getOrElse("0.1.0-alpha.1")
    implementation("tech.notifly:kmp:$notiflyKmpVersion")
}
