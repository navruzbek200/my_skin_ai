// Imported explicitly: inside the `android { }` block Gradle's own `java`
// extension shadows the java.* package, so `java.util.Properties` fails to
// resolve there.
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "uz.realbeauty.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    // Load release signing credentials from key.properties (never commit that file).
    // To create: keytool -genkey -v -keystore android/upload-keystore.jks
    //            -keyalg RSA -keysize 2048 -validity 10000 -alias upload
    // Then create android/key.properties with storeFile/storePassword/keyAlias/keyPassword.
    val keyPropertiesFile = rootProject.file("key.properties")
    val keyProperties = Properties().apply {
        if (keyPropertiesFile.exists()) load(keyPropertiesFile.inputStream())
    }
    // key.properties can exist while the keystore it points at does not (moved
    // machine, lost file). Signing must fall back to debug in that case rather
    // than failing the build with an opaque "keystore not found".
    val releaseKeystore = keyProperties.getProperty("storeFile")?.let { file(it) }
    val hasReleaseSigning = releaseKeystore?.exists() == true

    signingConfigs {
        create("release") {
            storeFile = releaseKeystore
            storePassword = keyProperties.getProperty("storePassword")
            keyAlias = keyProperties.getProperty("keyAlias")
            keyPassword = keyProperties.getProperty("keyPassword")
        }
    }

    defaultConfig {
        applicationId = "uz.realbeauty.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning)
                signingConfigs.getByName("release")
            else
                signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
