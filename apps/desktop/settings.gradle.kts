rootProject.name = "template-demo-desktop"

// Include the Kotlin multiplatform library as a composite build
includeBuild("../../platforms/kotlin") {
    dependencySubstitution {
        substitute(module("com.template:template-jvm")).using(project(":"))
    }
}
