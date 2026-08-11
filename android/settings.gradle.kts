pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    // START: FlutterFire Configuration
    // Pinned to 4.4.x: the Crashlytics plugin below is v3, which reads the app
    // id through an API that only exists from google-services 4.4.1 on.
    id("com.google.gms.google-services") version("4.4.2") apply false
    // Uploads the deobfuscation mapping and the native symbol table on every
    // release build. Without it a crash arrives in the console as raw
    // addresses and minified frames instead of readable stacks.
    id("com.google.firebase.crashlytics") version("3.0.2") apply false
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")
