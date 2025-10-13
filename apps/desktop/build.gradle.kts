plugins {
    kotlin("jvm") version "1.9.20"
    application
}

group = "dev.eaceto"
version = "1.0.0"

repositories {
    mavenCentral()
}

dependencies {
    // Template library - composite build dependency (resolves to local source)
    implementation("com.template:template-jvm:0.1.0")

    // Kotlin stdlib
    implementation(kotlin("stdlib"))
}

application {
    mainClass.set("dev.eaceto.templatedemo.MainKt")
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
    kotlinOptions {
        jvmTarget = "11"
    }
}

java {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
}

// Create a fat JAR with all dependencies
tasks.jar {
    manifest {
        attributes["Main-Class"] = "dev.eaceto.templatedemo.MainKt"
    }

    from(configurations.runtimeClasspath.get().map { if (it.isDirectory) it else zipTree(it) }) {
        exclude("META-INF/*.SF")
        exclude("META-INF/*.DSA")
        exclude("META-INF/*.RSA")
    }

    duplicatesStrategy = DuplicatesStrategy.EXCLUDE
}
