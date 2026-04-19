import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties().apply {
    val keystoreFile = rootProject.file("key.properties")
    if (keystoreFile.exists()) {
        FileInputStream(keystoreFile).use { load(it) }
    }
}

android {
    namespace = "io.khode.telegram_login_flutter_example"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "io.khode.telegram_login_flutter_example"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Signing configuration for both debug and release builds.
    //
    // Using the same upload keystore for both variants means the APK's
    // SHA-256 fingerprint is identical regardless of build type. That lets
    // the Telegram Login SDK's App-Link / package verification work with
    // `flutter run` (debug) and `flutter build apk --release` alike, using
    // the single fingerprint registered with BotFather.
    //
    // Credentials come from example/android/key.properties; if that file
    // is missing, each variant falls back to Android's default debug
    // keystore so `flutter run` still works on a fresh checkout.
    signingConfigs {
        create("upload") {
            val storeFileProp = keystoreProperties["storeFile"] as String?
            if (storeFileProp != null) {
                storeFile = rootProject.file(storeFileProp)
                storePassword = keystoreProperties["storePassword"] as String?
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
            }
        }
    }

    buildTypes {
        val hasUploadKeystore = (keystoreProperties["storeFile"] as String?) != null
        val signing = if (hasUploadKeystore) {
            signingConfigs.getByName("upload")
        } else {
            signingConfigs.getByName("debug")
        }

        getByName("debug") {
            signingConfig = signing
        }
        getByName("release") {
            signingConfig = signing
        }
    }
}

flutter {
    source = "../.."
}
