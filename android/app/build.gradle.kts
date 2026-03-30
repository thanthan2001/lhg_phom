plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
  
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.lhg_phom"
    compileSdk = flutter.compileSdkVersion
    ndkVersion =  "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
  
        applicationId = "com.example.lhg_phom"
  
  
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
  
  
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    
    sourceSets {
        getByName("main") {
            jniLibs.srcDirs("libs")
        }
    }
}
repositories {
    google()
    mavenCentral()
    flatDir {
        dirs("libs") 
    }
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib")
    implementation(mapOf("name" to "rfiddrive-release", "ext" to "aar"))
    implementation(mapOf("name" to "rfidV2.1", "ext" to "jar"))
}

flutter {
    source = "../.."
}
