pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "TemplateDemoAndroid"
include(":app")

// Include the Kotlin multiplatform library as a composite build
includeBuild("../../platforms/kotlin") {
    dependencySubstitution {
        substitute(module("com.template:template-android")).using(project(":"))
        substitute(module("com.template:template-android-debug")).using(project(":"))
    }
}
