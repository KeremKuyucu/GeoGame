import java.util.Properties
import java.io.FileInputStream
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.keremkuyucu.geogame"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }



    // ABI splits disabled for App Bundle builds (AAB handles this natively)
    // Enable only when building APKs directly
    // splits {
    //     abi {
    //         isEnable = true
    //         reset()
    //         include("armeabi-v7a", "arm64-v8a", "x86_64")
    //         isUniversalApk = true
    //     }
    // }

    defaultConfig {
        applicationId = "com.keremkuyucu.geogame"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Keystore configuration (Supports Vault path, relative path, and legacy path)
    val possibleKeyFiles = listOf(
        rootProject.projectDir.parentFile.parentFile.resolve("imza-bilgileri/key.properties"),
        file("C:\\Users\\kerem\\Projects\\imza-bilgileri\\key.properties")
    )
    val keystorePropertiesFile = possibleKeyFiles.firstOrNull { it.exists() } ?: file("C:\\Users\\kerem\\Projects\\imza-bilgileri\\key.properties")
    val keystoreProperties = Properties()
    val hasValidKeystore = if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
        !keystoreProperties.getProperty("storeFile").isNullOrEmpty()
    } else {
        false
    }

    signingConfigs {
        if (hasValidKeystore) {
            create("release") {
                val configuredStore = keystoreProperties.getProperty("storeFile")
                val storeF = file(configuredStore)
                storeFile = if (storeF.exists()) storeF else file(keystorePropertiesFile.parentFile, "ksk.jks")
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
        getByName("release") {
            if (hasValidKeystore) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                // Fallback to debug signing when no keystore is configured
                signingConfig = signingConfigs.getByName("debug")
                println("WARNING: No valid keystore found. Using debug signing for release build.")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

configurations.all {
    resolutionStrategy {
        force("androidx.browser:browser:1.10.0")
        force("androidx.core:core-ktx:1.18.0")
        force("androidx.core:core:1.18.0")
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}
