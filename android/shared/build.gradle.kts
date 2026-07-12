// Plain Kotlin shared by the phone app (:app) and the watch app (:wear):
// alarm settings, the wake window, the wake detector and the sync format.
plugins {
    id("org.jetbrains.kotlin.jvm")
}

java {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    testImplementation(kotlin("test-junit"))
}
