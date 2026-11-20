allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Pins every Android module (the app and every Flutter plugin module) to the NDK version declared in gradle.properties.
val pinnedNdkVersion: String = providers.gradleProperty("appNdkVersion").get()

fun applyPinnedNdkVersion(target: Project) {
    val androidDsl = target.extensions.findByName("android") ?: return
    androidDsl.javaClass.methods
        .firstOrNull { it.name == "setNdkVersion" && it.parameterCount == 1 }
        ?.invoke(androidDsl, pinnedNdkVersion)
}

subprojects {
    afterEvaluate { applyPinnedNdkVersion(project) }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
