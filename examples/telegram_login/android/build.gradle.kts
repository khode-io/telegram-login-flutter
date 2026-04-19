val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = java.util.Properties()
if (keyPropertiesFile.exists()) {
    keyProperties.load(keyPropertiesFile.inputStream())
}

allprojects {
    repositories {
        google()
        mavenCentral()
        // Telegram Login Android SDK is published only on GitHub Packages.
        // Credentials come from `gpr.user` / `gpr.key` in key.properties
        // (see example/android/key.properties). A GitHub Personal Access Token
        // with `read:packages` scope is required.
        maven {
            url = uri("https://maven.pkg.github.com/TelegramMessenger/telegram-login-android")
            credentials {
                username = keyProperties.getProperty("gpr.user")
                password = keyProperties.getProperty("gpr.key")
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
