allprojects {
    repositories {
        google()
        mavenCentral()
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

// Workaround: some older/unmaintained plugins (e.g. `telephony`) predate the
// Android Gradle Plugin's namespace requirement and never declared one in
// their own build.gradle. Inject a namespace for any library module that's
// missing it, so the build doesn't fail on their behalf.
// NOTE: uses pluginManager.withPlugin (not afterEvaluate) because Flutter's
// plugin loader can evaluate native plugin projects as a side effect of
// evaluating :app, which happens before our config would otherwise run.
subprojects {
    pluginManager.withPlugin("com.android.library") {
        extensions.configure<com.android.build.gradle.LibraryExtension> {
            if (namespace == null) {
                namespace = "com.finadvisor.plugins.${project.name.replace("-", "_")}"
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
