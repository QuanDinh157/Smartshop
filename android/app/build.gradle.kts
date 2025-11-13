plugins {
    id("com.android.application")
    id("kotlin-android")

    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.smartshop"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.smartshop"
        minSdk = flutter.minSdkVersion
        targetSdk = 33
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Để tích hợp bất kỳ SDK Firebase nào, bạn cần 2 dòng cơ bản này:

    // 1. Firebase Bill of Materials (BoM)
    // Giúp quản lý phiên bản của tất cả các thư viện Firebase một cách tự động và tương thích.
    implementation(platform("com.google.firebase:firebase-bom:32.7.4"))
    // *Lưu ý: Thay thế '32.7.4' bằng phiên bản BoM mới nhất mà Firebase Console đề xuất.*

    // 2. Thêm Firebase Analytics (Đây là thư viện cốt lõi nhất)
    implementation("com.google.firebase:firebase-analytics")

    // 3. (Tùy chọn) Thêm các SDK khác nếu bạn cần (ví dụ: Auth, Firestore,...)
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
}