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



    splits {
        abi {
            isEnable = true // ABI başına ayrı APK oluştur
            reset()         // Varsayılan ayarları sıfırla
            include("armeabi-v7a", "arm64-v8a", "x86_64") // Desteklenecek mimariler
            isUniversalApk = true // Tek bir evrensel APK oluşturma
        }
    }

    defaultConfig {
        applicationId = "com.keremkuyucu.geogame"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Keystore configuration
    val keystorePropertiesFile = file("C:\\Users\\kerem\\Projects\\imza-bilgileri\\key.properties")
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
                storeFile = file(keystoreProperties.getProperty("storeFile"))
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
