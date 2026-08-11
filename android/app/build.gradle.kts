// Imported explicitly: inside the `android { }` block Gradle's own `java`
// extension shadows the java.* package, so `java.util.Properties` fails to
// resolve there.
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
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

            // Off by default in a Flutter project, which ships every unused
            // class and resource of Firebase, ML Kit and Play Services to a
            // market where download size is a real cost. The keep rules the
            // shrinker cannot infer live in proguard-rules.pro.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )

            // Crashlytics can only symbolicate a native crash if the unstripped
            // libraries were uploaded at build time. Release-only: doing it for
            // debug builds would slow every local run for no benefit.
            configure<com.google.firebase.crashlytics.buildtools.gradle.CrashlyticsExtension> {
                nativeSymbolUploadEnabled = true
                unstrippedNativeLibsDir = "build/app/intermediates/merged_native_libs/release/out/lib"
            }
        }
    }
}

flutter {
    source = "../.."
}
