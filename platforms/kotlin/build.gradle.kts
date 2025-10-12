plugins {
    kotlin("multiplatform") version "1.9.20"
    id("com.android.library") version "8.1.4"
    id("org.jetbrains.dokka") version "1.9.20"
    id("maven-publish")
}

group = "com.template"
version = "0.1.0"

repositories {
    mavenCentral()
    google()
}

kotlin {
    // Android target
    androidTarget {
        publishLibraryVariants("release", "debug")
    }

    // JVM target (Desktop)
    jvm {
        compilations.all {
            kotlinOptions.jvmTarget = "11"
        }
        testRuns["test"].executionTask.configure {
            useJUnitPlatform()
        }
    }

    sourceSets {
        val commonMain by getting {
            dependencies {
                implementation("net.java.dev.jna:jna:5.13.0")
            }
        }
        val commonTest by getting {
            dependencies {
                implementation(kotlin("test"))
            }
        }
        val androidMain by getting
        val jvmMain by getting
    }
}

android {
    namespace = "com.template"
    compileSdk = 34
    defaultConfig {
        minSdk = 24
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}

// Dokka configuration for documentation generation
tasks.dokkaHtml.configure {
    outputDirectory.set(file("build/dokka/html"))

    dokkaSourceSets {
        configureEach {
            displayName.set("Template Library")
            includeNonPublic.set(false)
            skipEmptyPackages.set(true)
            skipDeprecated.set(false)
            reportUndocumented.set(true)
            jdkVersion.set(11)

            // Module documentation
            includes.from("README.md")

            // Source links
            sourceLink {
                localDirectory.set(file("src"))
                remoteUrl.set(uri("https://github.com/eaceto/rust-multiplatform-template-lib/tree/main/platforms/kotlin/src").toURL())
                remoteLineSuffix.set("#L")
            }
        }
    }
}
