plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.greetyy.lucid"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // The watch app (:wear) uses the same id; the Wear Data Layer needs it.
        applicationId = "com.greetyy.lucid"
        // Samsung Health Data SDK needs Android 10.
        minSdk = 29
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // shortcut: release is signed with the debug key, like :wear (the Data Layer
            // needs matching keys); add a real upload key before publishing.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// Samsung Health Data SDK is a vendor binary kept out of git (see README).
val samsungHealthAar = file("libs/samsung-health-data-api-1.1.0.aar")

dependencies {
    check(samsungHealthAar.exists()) {
        "Copy samsung-health-data-api-1.1.0.aar into android/app/libs (README, Samsung Health)."
    }
    implementation(files(samsungHealthAar))
    // Runtime dependencies of the Samsung SDK, which a local AAR does not bring along.
    implementation("com.google.code.gson:gson:2.11.0")
    implementation("org.jetbrains.kotlin:kotlin-parcelize-runtime:2.3.20")
    implementation(project(":shared"))
    implementation("androidx.core:core-ktx:1.17.0")
    implementation("com.google.android.gms:play-services-wearable:19.0.0")
    implementation("androidx.wear:wear-remote-interactions:1.1.0")
    implementation("androidx.concurrent:concurrent-futures-ktx:1.2.0")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.10.2")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-play-services:1.10.2")
}
