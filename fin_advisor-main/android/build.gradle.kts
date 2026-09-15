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
subprojects {
    afterEvaluate {
        if (project.plugins.hasPlugin("com.android.library")) {
            project.extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
                ?.let { ext ->
                    if (ext.namespace == null) {
                        ext.namespace = "com.finadvisor.plugins.${project.name.replace("-", "_")}"
                    }
                }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
